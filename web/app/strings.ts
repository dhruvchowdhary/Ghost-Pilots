/// The public page's words. The dashboard keeps its own in admin/strings.ts.
export const Strings = {
  site: {
    name: "Ghost Pilots",
    description: "A space shooter for iPhone and iPad: solo, campaign, boss fights and online battles.",
  },
  home: {
    get: "Get it on the App Store",
  },
} as const;

/// The live listing, the same app the dashboard's App Store tab reads.
export const APP_STORE_URL = "https://apps.apple.com/us/app/ghost-pilots/id1538606743";
