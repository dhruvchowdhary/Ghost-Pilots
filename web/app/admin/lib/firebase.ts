import { createPrivateKey, sign, type KeyObject } from "node:crypto";
import { AdminStrings } from "../strings";
import { DashboardError } from "./data";
import { requireAdmin } from "./session";

/// Reads from the game's Firebase Realtime Database, over its REST API, as a
/// service account. The database's rules keep everyone else out (a plain read
/// is a 401), and a service account's token goes past them, so this is the
/// only door and it's read-only: nothing in the dashboard writes.
///
/// The token is the standard Google one: a JWT signed with the account's
/// private key, swapped at Google's token endpoint for an hour's access
/// token. Done by hand with node:crypto rather than with firebase-admin,
/// which would bring a large dependency for two HTTP calls.
///
/// Every read checks the session first, whichever page asked.

const t = AdminStrings.problem;

/// The live database, from APBOv2/GoogleService-Info.plist.
const LIVE_DATABASE = "https://ghostpilots-d199f-default-rtdb.firebaseio.com";

const SCOPES = [
  "https://www.googleapis.com/auth/firebase.database",
  "https://www.googleapis.com/auth/userinfo.email",
].join(" ");

// ---------------------------------------------------------------------------
// The key
// ---------------------------------------------------------------------------

type ServiceAccount = { email: string; key: KeyObject; keyId: string | undefined; tokenUri: string };

let account: { raw: string; parsed: ServiceAccount } | null = null;

/// The service account from FIREBASE_SERVICE_ACCOUNT: the JSON file the
/// Firebase console downloads, pasted whole, or base64 of it.
function serviceAccount(): ServiceAccount {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT?.trim();
  if (!raw) throw new DashboardError(t.noKey);
  if (account?.raw === raw) return account.parsed;

  let json: { client_email?: string; private_key?: string; private_key_id?: string; token_uri?: string };
  try {
    json = JSON.parse(raw.startsWith("{") ? raw : Buffer.from(raw, "base64").toString("utf8"));
  } catch {
    throw new DashboardError(t.badServiceAccount);
  }
  if (!json.client_email || !json.private_key) throw new DashboardError(t.badServiceAccount);

  let key: KeyObject;
  try {
    key = createPrivateKey(json.private_key.replace(/\\n/g, "\n"));
  } catch {
    throw new DashboardError(t.badServiceAccount);
  }

  const parsed = {
    email: json.client_email,
    key,
    keyId: json.private_key_id,
    tokenUri: json.token_uri || "https://oauth2.googleapis.com/token",
  };
  account = { raw, parsed };
  return parsed;
}

let minted: { token: string; email: string; until: number } | null = null;
let minting: { email: string; token: Promise<string> } | null = null;

/// An access token for the database. Google's last an hour; these are reused
/// for fifty minutes. A page's reads start together, so they share one trip
/// to Google rather than each making their own.
async function accessToken(): Promise<string> {
  const sa = serviceAccount();
  if (minted && minted.email === sa.email && minted.until > Date.now()) return minted.token;
  if (minting?.email === sa.email) return minting.token;

  const token = mint(sa);
  minting = { email: sa.email, token };
  try {
    return await token;
  } finally {
    if (minting?.token === token) minting = null;
  }
}

async function mint(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const part = (value: object) => Buffer.from(JSON.stringify(value)).toString("base64url");
  const unsigned = `${part({ alg: "RS256", typ: "JWT", ...(sa.keyId ? { kid: sa.keyId } : {}) })}.${part({
    iss: sa.email,
    scope: SCOPES,
    aud: sa.tokenUri,
    iat: now,
    exp: now + 60 * 60,
  })}`;
  const assertion = `${unsigned}.${sign("sha256", Buffer.from(unsigned), sa.key).toString("base64url")}`;

  let response: Response;
  try {
    response = await fetch(sa.tokenUri, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion }),
      cache: "no-store",
    });
  } catch {
    throw new DashboardError(t.unreachable);
  }
  const body = (await response.json().catch(() => ({}))) as {
    access_token?: string;
    expires_in?: number;
    error?: string;
    error_description?: string;
  };
  if (!response.ok || !body.access_token) {
    // invalid_grant is what a deleted key or a deleted account gets.
    if (response.status === 400 || response.status === 401) throw new DashboardError(t.badKey);
    throw new DashboardError(t.other(`${response.status} ${body.error_description ?? body.error ?? ""}`.trim()));
  }

  const seconds = Math.min(body.expires_in ?? 3600, 3600);
  minted = { token: body.access_token, email: sa.email, until: Date.now() + (seconds - 600) * 1000 };
  return minted.token;
}

// ---------------------------------------------------------------------------
// Reads
// ---------------------------------------------------------------------------

function databaseUrl(): string {
  return (process.env.FIREBASE_DATABASE_URL?.trim() || LIVE_DATABASE).replace(/\/+$/, "");
}

async function fetchPath<T>(path: string): Promise<T | null> {
  const token = await accessToken();
  let response: Response;
  try {
    response = await fetch(`${databaseUrl()}/${path}.json`, {
      headers: { Authorization: `Bearer ${token}` },
      cache: "no-store",
    });
  } catch {
    throw new DashboardError(t.unreachable);
  }
  if (!response.ok) {
    const text = await response.text();
    if (response.status === 401 || response.status === 403) {
      // A token Google has since revoked reads the same as one that was never
      // allowed, so the next try mints a fresh one before saying so again.
      minted = null;
      throw new DashboardError(t.forbidden);
    }
    if (response.status === 404) throw new DashboardError(t.badDatabase);
    let detail = text.slice(0, 200);
    try {
      detail = (JSON.parse(text) as { error?: string }).error ?? detail;
    } catch {}
    throw new DashboardError(t.other(`${response.status} ${detail}`));
  }
  return (await response.json()) as T | null;
}

/// How long a read is reused. The game writes constantly while people play,
/// so this is short, but long enough that moving between tabs (each of which
/// reads most of the database) doesn't download it again every time.
const FRESH_MS = 60_000;

const recent = new Map<string, { at: number; value: Promise<unknown> }>();

/// A whole node of the database, or null where there's nothing. Shared across
/// requests on the same server for a minute; a failed read isn't kept.
///
/// Not `unstable_cache`: Vercel's data cache refuses entries over 2 MB, and
/// the player list can be bigger than that. The pages boil it down instead.
export async function read<T>(path: string): Promise<T | null> {
  await requireAdmin();
  const now = Date.now();
  // Each player's page is its own path, so old ones are let go as we pass.
  for (const [key, entry] of recent) if (now - entry.at >= FRESH_MS) recent.delete(key);
  const hit = recent.get(path);
  if (hit) return hit.value as Promise<T | null>;

  const value = fetchPath<T>(path);
  recent.set(path, { at: now, value });
  value.catch(() => {
    if (recent.get(path)?.value === value) recent.delete(path);
  });
  return value;
}
