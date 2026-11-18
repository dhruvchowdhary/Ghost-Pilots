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

export type SceneKind = "play" | "menu";

/// `Users/<device>/Play/<scene>`: each scene class the game shows, named the
/// way a player would know it. `play` is a game being played; `menu` is
/// everything around it. A scene missing here still shows, as its class name,
/// counted as a menu.
export const SCENES: Record<string, { name: string; kind: SceneKind; group: string }> = {
  GameScene: { name: "Endless", kind: "play", group: "Solo" },
  Level1: { name: "Level 1", kind: "play", group: "Solo" },
  Level2: { name: "Level 2", kind: "play", group: "Solo" },
  Level3: { name: "Level 3", kind: "play", group: "Solo" },
  TurretBoss: { name: "Turret boss", kind: "play", group: "Solo" },
  Tutorial: { name: "Tutorial", kind: "play", group: "Solo" },
  CPLevel1: { name: "Campaign 1", kind: "play", group: "Campaign" },
  CPLevel2: { name: "Campaign 2", kind: "play", group: "Campaign" },
  CPLevel3: { name: "Campaign 3", kind: "play", group: "Campaign" },
  CPLevel4: { name: "Campaign 4", kind: "play", group: "Campaign" },
  GameSceneOnline: { name: "Free for all", kind: "play", group: "Online" },
  AstroBall: { name: "Astroball", kind: "play", group: "Online" },
  Infection: { name: "Infection", kind: "play", group: "Online" },
  LoadIntro: { name: "Intro", kind: "menu", group: "Menus" },
  MainMenu: { name: "Main menu", kind: "menu", group: "Menus" },
  SoloMenu: { name: "Solo menu", kind: "menu", group: "Menus" },
  LoadLevelsMenu: { name: "Levels menu", kind: "menu", group: "Menus" },
  TurretBossMenu: { name: "Turret boss menu", kind: "menu", group: "Menus" },
  Campaign: { name: "Campaign map", kind: "menu", group: "Menus" },
  OnlineMenu: { name: "Online menu", kind: "menu", group: "Menus" },
  HostMenu: { name: "Hosting a game", kind: "menu", group: "Menus" },
  LobbyMenu: { name: "Lobby", kind: "menu", group: "Menus" },
  Shop: { name: "Shop", kind: "menu", group: "Menus" },
};

export function scene(id: string) {
  return SCENES[id] ?? { name: id, kind: "menu" as const, group: "Menus" };
}
