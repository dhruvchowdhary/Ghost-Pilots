/// Names for the raw values the game writes to Firebase, as the game itself
/// shows them. Each list is the game's own, from the Swift source; a value
/// the game adds later still shows, as itself, until it's named here.

/// `Games/<code>/Mode`. HostMenu.swift, `modeArray`.
export const MODES: Record<string, string> = {
  ffa: "Free for all",
  astroball: "Astroball",
  infection: "Infection",
};

/// `Games/<code>/Map`. HostMenu.swift, `mapArray`.
export const MAPS: Record<string, string> = {
  OnlineCubis: "Cubis",
  OnlineTrisen: "Trisen",
  OnlineHex: "Hex",
};

export type ShopKind = "decal" | "trail";

/// Shop.swift: `decalStrings` and `trailStrings` with their prices and the
/// titles the shop prints. The first of each kind is what every player starts
/// with, so it's never counted as bought.
export const SHOP: readonly { id: string; kind: ShopKind; name: string; price: number; starter: boolean }[] = [
  { id: "DEFAULTDECAL", kind: "decal", name: "Default decal", price: 0, starter: true },
  { id: "TIGER", kind: "decal", name: "Tiger", price: 500, starter: false },
  { id: "SWIRL", kind: "decal", name: "Swirl", price: 500, starter: false },
  { id: "trailDefault", kind: "trail", name: "Default trail", price: 0, starter: true },
  { id: "trailLightning", kind: "trail", name: "Bolt", price: 200, starter: false },
  { id: "trailHeart", kind: "trail", name: "Heart", price: 200, starter: false },
];

export const STARTERS = new Set(SHOP.filter((item) => item.starter).map((item) => item.id));

/// What a decal or trail is called, whatever the game wrote.
export function itemName(id: string): string {
  return SHOP.find((item) => item.id === id)?.name ?? id;
}

export function modeName(mode: string | null): string | null {
  return mode ? (MODES[mode] ?? mode) : null;
}

export function mapName(map: string | null): string | null {
  return map ? (MAPS[map] ?? map) : null;
}

/// Balance bands for the overview. The edges are the shop's prices, so each
/// band says what a player could afford.
export const BALANCES: readonly { key: string; label: string; hint?: string; min: number; max: number }[] = [
  { key: "none", label: "None", min: 0, max: 0 },
  { key: "under-trail", label: "1 to 199", hint: "Not enough for anything yet", min: 1, max: 199 },
  { key: "trail", label: "200 to 499", hint: "Enough for a trail", min: 200, max: 499 },
  { key: "decal", label: "500 to 1,399", hint: "Enough for a decal", min: 500, max: 1399 },
  { key: "everything", label: "1,400 to 9,999", hint: "Enough for the whole shop", min: 1400, max: 9999 },
  { key: "rich", label: "10,000 or more", min: 10_000, max: Number.POSITIVE_INFINITY },
];
