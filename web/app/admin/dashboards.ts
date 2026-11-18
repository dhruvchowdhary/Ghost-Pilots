/// The admin dashboards the switcher at the top of the sidebar moves between.
///
/// Each app keeps its own dashboard in its own repo and on its own domain:
/// FitPals' at fitpals.dhrooby.com/admin (the SweatHearts repo), Whensday's
/// at w.dhrooby.com/admin (the Whensday repo), and Ghost Pilots' at
/// ghostpilots.dhrooby.com/admin (the Ghost-Pilots repo). Each repo holds a
/// copy of this file at `web/app/admin/dashboards.ts`. None holds another's
/// database key, so switching is a plain link and each asks for its own
/// password the first time.
///
/// Keep the three copies in step: same entries, same order, only `CURRENT`
/// differs. The current one links to `/admin` rather than its domain, so the
/// switcher stays put on a local `npm run dev`.

export type DashboardKey = "fitpals" | "whensday" | "ghostpilots";

/// The app as App Store Connect knows it, for the App Store tab
/// (`lib/appstore.ts`, also the same in every repo).
///
/// `id` is Apple's, the number in every store link. `sku` is what the sales
/// reports file an in-app purchase under, as the parent of the thing bought.
/// `sells` is whether there's anything to buy, which decides whether the tab
/// shows proceeds and purchases at all.
export type AppStoreApp = { id: string; sku: string; sells: boolean };

export const DASHBOARDS: readonly {
  key: DashboardKey;
  name: string;
  url: string;
  mark: string;
  initial: string;
  appStore: AppStoreApp;
}[] = [
  {
    key: "fitpals",
    name: "FitPals",
    url: "https://fitpals.dhrooby.com/admin",
    mark: "#5c9a3f",
    initial: "F",
    appStore: { id: "6816596309", sku: "fitpals-ios", sells: true },
  },
  {
    key: "whensday",
    name: "Whensday",
    url: "https://w.dhrooby.com/admin",
    mark: "#1a2130",
    initial: "W",
    appStore: { id: "6804535586", sku: "whensday", sells: false },
  },
  {
    // The original 2020 listing (bundle edu.astroparty), the one the repo
    // ships. Not 6784017006, "Ghost Pilots - Space Game": that listing was
    // made for a bundle id change that was later undone, and nothing ships
    // to it.
    key: "ghostpilots",
    name: "Ghost Pilots",
    url: "https://ghostpilots.dhrooby.com/admin",
    mark: "#152044",
    initial: "G",
    appStore: { id: "1538606743", sku: "vincentanddhruv", sells: false },
  },
];

export const CURRENT: DashboardKey = "ghostpilots";

/// This dashboard's own entry.
export const CURRENT_DASHBOARD = DASHBOARDS.find((d) => d.key === CURRENT) ?? DASHBOARDS[0];
