import { createHash, createHmac, timingSafeEqual } from "node:crypto";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";

/// Who may look at the dashboard: whoever knows `ADMIN_PASSWORD`.
///
/// One password rather than accounts, because there's one person reading this
/// and the game has no accounts of its own to sign in with. The same scheme as
/// the FitPals and Whensday dashboards, with its own cookie and its own key, so
/// a session on one is no use on another.
///
/// The session is a cookie holding an expiry and an HMAC of it. The key is
/// derived from the password, so changing the password signs every browser
/// out, and there's no second secret to keep. Nothing in the cookie is secret
/// on its own; it only proves the holder typed the password before it expired.
///
/// Checked where the data is read, not only where a page starts: a layout
/// doesn't re-render on every navigation, and `read` in firebase.ts refuses to
/// make a call without a valid session no matter which page asked.

export const SESSION_COOKIE = "ghostpilots_admin";
/// The browser's time zone, sent along with the password, so "today" on the
/// dashboard is the admin's today.
export const TIME_ZONE_COOKIE = "ghostpilots_admin_tz";
export const SESSION_SECONDS = 60 * 60 * 24 * 14;

/// Shorter than this and the dashboard stays off. It guards every player's
/// saved data and a key that reads the whole database, so a short password is
/// treated as no password.
const MINIMUM_LENGTH = 12;

export function adminPassword(): string | null {
  const password = process.env.ADMIN_PASSWORD;
  return password && password.length >= MINIMUM_LENGTH ? password : null;
}

function signature(expires: number, password: string): string {
  const key = createHash("sha256").update(`ghostpilots-admin\u0000${password}`).digest();
  return createHmac("sha256", key).update(`v1.${expires}`).digest("base64url");
}

export function newSessionValue(password: string): string {
  const expires = Date.now() + SESSION_SECONDS * 1000;
  return `v1.${expires}.${signature(expires, password)}`;
}

/// Equal-length digests, so the comparison takes as long whatever was typed.
export function passwordMatches(given: string, password: string): boolean {
  const a = createHash("sha256").update(given).digest();
  const b = createHash("sha256").update(password).digest();
  return timingSafeEqual(a, b);
}

export async function isSignedIn(): Promise<boolean> {
  const password = adminPassword();
  if (!password) return false;

  const value = (await cookies()).get(SESSION_COOKIE)?.value;
  if (!value) return false;

  const [version, expiresText, given] = value.split(".");
  const expires = Number(expiresText);
  if (version !== "v1" || !given || !Number.isFinite(expires) || expires < Date.now()) {
    return false;
  }

  const expected = Buffer.from(signature(expires, password));
  const actual = Buffer.from(given);
  return expected.length === actual.length && timingSafeEqual(expected, actual);
}

/// Sends anyone without a session to the login page.
export async function requireAdmin(): Promise<void> {
  if (!(await isSignedIn())) redirect("/admin/login");
}

export function isTimeZone(zone: string): boolean {
  if (!zone || zone.length > 64) return false;
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: zone });
    return true;
  } catch {
    return false;
  }
}

/// Where the admin's days start and end. UTC until the login form has said.
export async function adminTimeZone(): Promise<string> {
  const zone = (await cookies()).get(TIME_ZONE_COOKIE)?.value ?? "";
  return isTimeZone(zone) ? zone : "UTC";
}
