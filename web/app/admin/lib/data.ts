import { STARTERS } from "../labels";
import { read } from "./firebase";

/// The dashboard's reads, from the game's Firebase Realtime Database
/// (`lib/firebase.ts` does the talking). Three nodes hold everything:
///
/// - `Users/<device>`: `Polynite`, the balance as a string, and `ShopStuff`,
///   the shop as a JSON string (ShopPayload.swift). Written for every install
///   the first time it opens (LoadIntro.swift).
/// - `systemID/<device>`: the online name, once they've picked one
///   (OnlineMenu.swift).
/// - `Games/<code>`: an online game or lobby, and `Games/LFG/<code>` for the
///   public ones looking for players (GameData.swift, MultiplayerHandler.swift).
///
/// `<device>` is `identifierForVendor`, so a player is a device and a
/// reinstall is a new player. Nothing anywhere carries a date.
///
/// Every value was written by some version of the app, so none of it is
/// trusted to have the shape the current one writes.

/// A setup problem or an error from Firebase, already in words for the page.
export class DashboardError extends Error {}

// ---------------------------------------------------------------------------
// Players
// ---------------------------------------------------------------------------

export type Player = {
  id: string;
  name: string | null;
  polynite: number;
  decals: string[];
  trails: string[];
  wearingDecal: string | null;
  wearingTrail: string | null;
  /// Whether they've ever opened the shop. Until then there's no ShopStuff
  /// and they have the starters only.
  shop: boolean;
  /// Decals and trails beyond the ones everyone starts with.
  bought: number;
};

type RawUser = { Polynite?: unknown; ShopStuff?: unknown };
type RawShop = { lockerDecals?: unknown; lockerTrails?: unknown; equippedDecal?: unknown; equippedTrail?: unknown };

function toCount(value: unknown): number {
  const n = typeof value === "number" ? value : typeof value === "string" ? Number(value.trim()) : NaN;
  return Number.isFinite(n) ? Math.trunc(n) : 0;
}

function strings(value: unknown): string[] {
  return Array.isArray(value) ? [...new Set(value.filter((v): v is string => typeof v === "string" && v !== ""))] : [];
}

function text(value: unknown): string | null {
  return typeof value === "string" && value.trim() !== "" ? value : null;
}

function readShop(value: unknown): RawShop | null {
  if (value && typeof value === "object") return value as RawShop;
  if (typeof value !== "string") return null;
  try {
    const parsed = JSON.parse(value) as unknown;
    return parsed && typeof parsed === "object" ? (parsed as RawShop) : null;
  } catch {
    return null;
  }
}

function toPlayer(id: string, raw: RawUser | null, name: string | null): Player {
  const shop = readShop(raw?.ShopStuff);
  const decals = shop ? strings(shop.lockerDecals) : [];
  const trails = shop ? strings(shop.lockerTrails) : [];
  return {
    id,
    name,
    polynite: toCount(raw?.Polynite),
    decals,
    trails,
    wearingDecal: shop ? text(shop.equippedDecal) : null,
    wearingTrail: shop ? text(shop.equippedTrail) : null,
    shop: shop !== null,
    bought: [...decals, ...trails].filter((item) => !STARTERS.has(item)).length,
  };
}

/// Everyone: each device under `Users`, with its online name. A device that
/// picked a name but has no `Users` entry (an old build, or a deleted row) is
/// still a player, with nothing else to show.
export async function getPlayers(): Promise<Player[]> {
  const [users, names] = await Promise.all([
    read<Record<string, RawUser | null>>("Users"),
    read<Record<string, unknown>>("systemID"),
  ]);
  const ids = new Set([...Object.keys(users ?? {}), ...Object.keys(names ?? {})]);
  return [...ids].map((id) => toPlayer(id, users?.[id] ?? null, text(names?.[id])));
}

/// Firebase keys can hold anything but these, and device ids are UUIDs, so
/// anything else in the URL isn't a player.
export function isPlayerId(id: string): boolean {
  return /^[^.#$[\]/\u0000-\u001f\u007f]{1,128}$/.test(id);
}

/// One player, or null if the game has nothing under that id.
export async function getPlayer(id: string): Promise<Player | null> {
  const [user, name] = await Promise.all([
    read<RawUser>(`Users/${encodeURIComponent(id)}`),
    read<unknown>(`systemID/${encodeURIComponent(id)}`),
  ]);
  if (user === null && name === null) return null;
  return toPlayer(id, user, text(name));
}

// ---------------------------------------------------------------------------
// Online games
// ---------------------------------------------------------------------------

/// Where someone is in a game's `PlayerList`: still there, gone, or kicked.
/// The game writes these as "PePeNotGone", "PePeGone" and "PePeKicked".
export type Seat = "here" | "left" | "kicked";

export type Game = {
  code: string;
  /// "Lobby" or "Game" as the game writes them, or null on a fragment.
  status: string | null;
  mode: string | null;
  map: string | null;
  host: string | null;
  seats: { name: string; seat: Seat }[];
  public: boolean;
  /// Listed in `Games/LFG`, where quick play looks for a lobby to join.
  queued: boolean;
};

type RawGame = {
  Status?: unknown;
  Mode?: unknown;
  Map?: unknown;
  Host?: unknown;
  PlayerList?: unknown;
  isPublic?: unknown;
};

function seat(value: unknown): Seat {
  if (value === "PePeNotGone") return "here";
  if (value === "PePeKicked") return "kicked";
  return "left";
}

export async function getGames(): Promise<Game[]> {
  const games = await read<Record<string, unknown>>("Games");
  const all = games ?? {};
  const queue = all.LFG && typeof all.LFG === "object" ? new Set(Object.keys(all.LFG)) : new Set<string>();

  return Object.entries(all)
    .filter(([code, raw]) => code !== "LFG" && raw && typeof raw === "object")
    .map(([code, value]) => {
      const raw = value as RawGame;
      const list = raw.PlayerList && typeof raw.PlayerList === "object" ? (raw.PlayerList as Record<string, unknown>) : {};
      return {
        code,
        status: text(raw.Status),
        mode: text(raw.Mode),
        map: text(raw.Map),
        host: text(raw.Host),
        seats: Object.entries(list).map(([name, v]) => ({ name, seat: seat(v) })),
        public: raw.isPublic === "TRUE" || raw.isPublic === true,
        queued: queue.has(code),
      };
    });
}

/// Someone is still in it. Without that a game is left behind, whatever its
/// status says: nobody will ever read it again.
export function isLive(game: Game): boolean {
  return game.status !== null && game.seats.some((s) => s.seat === "here");
}

export function isPlaying(game: Game): boolean {
  return isLive(game) && game.status === "Game";
}

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

/// Runs the reads a page needs and hands back either all of them or the one
/// problem worth putting on screen. Anything that isn't a `DashboardError` -
/// a redirect to the login page, say - is left to propagate.
export async function attempt<T>(work: Promise<T>): Promise<{ data: T } | { problem: string }> {
  try {
    return { data: await work };
  } catch (error) {
    if (error instanceof DashboardError) return { problem: error.message };
    throw error;
  }
}
