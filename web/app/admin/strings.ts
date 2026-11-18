/// Every word the admin dashboard shows: one place to read the copy back,
/// nothing buried in a view. Names for modes, maps and shop items live next
/// door in labels.ts.
export const AdminStrings = {
  title: "Ghost Pilots Admin",
  wordmark: "Ghost Pilots",
  badge: "Admin",
  switcher: {
    label: "Switch dashboard",
    current: "You're here",
  },
  nav: {
    label: "Dashboard",
    overview: "Overview",
    appStore: "App Store",
    players: "Players",
    games: "Online games",
  },
  signOut: "Sign out",

  login: {
    heading: "Admin",
    caption: "The dashboard behind Ghost Pilots. Enter the admin password to continue.",
    password: "Password",
    submit: "Sign in",
    submitting: "Signing in",
    wrong: "That password isn't right.",
    unconfigured:
      "The dashboard is switched off. Set ADMIN_PASSWORD (at least 12 characters) on the Vercel project, then redeploy.",
  },

  filters: {
    range: "Period",
    ranges: { "7d": "7 days", "30d": "30 days", "90d": "90 days" },
  },

  overview: {
    heading: "Overview",
    caption:
      "Everything the game keeps in Firebase, added up. Until 3.4 it saved no dates, so most of this is totals as of now; downloads by day are on the App Store tab.",
    players: "Players",
    playersSub: (named: number) => `${named.toLocaleString("en-US")} picked an online name`,
    playersHint:
      "Every install that has opened the game since it began saving Polynite. A reinstall counts again, because the game keys everything to the device.",
    online: "In online games",
    onlineSub: (games: number, lobbies: number) =>
      `${games} ${games === 1 ? "game" : "games"} playing · ${lobbies} ${lobbies === 1 ? "lobby" : "lobbies"} open`,
    onlineHint:
      "Players the database has in a game or lobby. From versions after 3.4 the server marks anyone gone the moment their app closes or drops offline; an older version can still leave a seat behind.",
    polynite: "Polynite held",
    polyniteSub: (median: number, left: number) =>
      left === 0
        ? `Median ${median.toLocaleString("en-US")} a player`
        : `Median ${median.toLocaleString("en-US")} a player · ${left} over a million left out`,
    polyniteHint:
      "Every player's balance, added up: what they have now, not what they've earned. Balances over a million are left out of the total, because a few run to 22 digits and would drown out everyone else. They still count everywhere else.",
    buyers: "Bought from the shop",
    buyersSub: (pct: string) => `${pct} of players`,
    buyersHint: "Players who own at least one decal or trail beyond the defaults everyone starts with.",
    shopHeading: "What players own",
    shopCaption: (decal: number, trail: number) =>
      `Every player, and how many own each item. A decal costs ${decal} Polynite and a trail ${trail}.`,
    wearing: (n: number) => `${n.toLocaleString("en-US")} wearing it`,
    shopOf: (n: number) => `of ${n.toLocaleString("en-US")} players`,
    dailyHeading: "Day by day",
    dailyCaption:
      "From versions of the game after 3.4, which save the days they're opened and for how long. Days are UTC.",
    dailyEmpty:
      "Nothing yet. Versions of the game after 3.4 save this, so it fills in as players update.",
    dailyActive: "Players who opened it",
    dailyMinutes: "Minutes in the game",
    today: (n: number) => `${n.toLocaleString("en-US")} today`,
    inPeriod: (n: number, days: number) => `${n.toLocaleString("en-US")} in ${days} days`,
    showTable: "Show the numbers",
    tableDay: "Day",
    describe: (name: string, days: number, peak: number, peakDay: string) =>
      `${name} per day over ${days} days. Highest ${peak} on ${peakDay}. The table below has every day.`,
    playHeading: "What people play",
    playCaption:
      "Every mode, how often it was started and how long people stayed, added up since each player updated to a version that records it.",
    playEmpty: "Nothing yet. Versions of the game after 3.4 record this, so it fills in as players update.",
    menusHeading: "Menus",
    mode: "Mode",
    plays: "Plays",
    time: "Time",
    perPlay: "Per play",
    balanceHeading: "How much Polynite players have",
    balanceCaption: "Every player's balance right now. Solo runs, the turret boss and campaign levels pay it out.",
    empty: "No players in the database yet.",
  },

  // The same in every dashboard's repo, like lib/appstore.ts that it words.
  appStore: {
    heading: "App Store",
    caption: "What Apple reports: downloads, money, the store page and ratings.",
    live: (version: string, date: string) => `Version ${version} has been on sale since ${date}.`,
    notConnectedHeading: "App Store Connect isn't connected",

    downloads: "Downloads",
    downloadsSub: (n: number) => (n === 0 ? "No redownloads" : `Plus ${n} ${n === 1 ? "redownload" : "redownloads"}`),
    downloadsHint: "First-time downloads: someone getting the app on an Apple Account that never had it.",
    proceeds: "Proceeds",
    proceedsSub: "After Apple's commission",
    proceedsPlus: (amounts: string) => `Plus ${amounts}`,
    proceedsHint: "What Apple pays out, in each storefront's own currency. Never converted.",
    paid: "Paid purchases",
    paidSub: (renewals: number, trials: number) =>
      `${renewals} ${renewals === 1 ? "renewal" : "renewals"} · ${trials} free ${trials === 1 ? "trial" : "trials"} started`,
    updates: "Updates",
    updatesSub: "Installs of a newer version",
    rating: "Rating",
    ratingValue: (average: number) => `${average.toFixed(1)} ★`,
    ratingNone: "None yet",
    ratingSub: (count: number, shown: string) =>
      count === 0 ? "No ratings on the US App Store" : `From ${shown} ${count === 1 ? "rating" : "ratings"} on the US App Store`,

    dailyHeading: "Day by day",
    dailyCaption: "From Apple's daily sales reports, which close each day on Pacific time.",
    through: (date: string) => `Apple has only posted up to ${date} so far.`,
    nothingPosted: "Apple hasn't posted any of these days yet. A day is complete by 5am Pacific the morning after.",
    dailyDownloads: "First-time downloads",
    dailyRedownloads: "Redownloads",
    dailyUpdates: "Updates",
    dailyTrials: "Free trials started",
    dailyPaid: "Paid purchases",
    inPeriod: (n: number, days: number) => `${n} in ${days} days`,
    describe: (name: string, days: number, peak: number, peakDay: string) =>
      `${name} per day over ${days} days. Highest ${peak} on ${peakDay}. The table below has every day.`,
    showTable: "Show the numbers",
    tableDay: "Day",

    storeHeading: "On the App Store",
    storeCaption:
      "How often the app turned up in the store, and how often someone opened its page. From App Analytics: a day takes up to three days to settle, and Apple keeps five weeks.",
    impressions: "Impressions",
    impressionsHint: "Times the icon was seen in a list or in search results",
    pageViews: "Page views",
    pageViewsHint: "Times someone opened the app's own page",
    covers: (from: string, to: string) => `App Analytics has ${from} to ${to} of this period.`,
    storeEmpty: "App Analytics has nothing for this period yet.",
    analyticsOff:
      "App Analytics isn't on for this app, so Apple isn't making these reports. An Admin key has to ask for them once; web/README.md says how.",
    analyticsPreparing:
      "App Analytics is on, and Apple is preparing the first reports. They usually take a day or two to arrive.",
    analyticsStopped:
      "Apple stopped making these reports because nothing collected them for a while. An Admin key has to ask again; web/README.md says how.",

    sourcesHeading: "Where downloads come from",
    sourcesCaption: "First-time downloads by how people reached the app, from App Analytics.",
    sourcesEmpty: "No first-time downloads in App Analytics for this period.",
    sourcesOf: (n: number) => `of ${n} first-time downloads`,
    sources: {
      "app store search": "App Store search",
      "app store browse": "App Store browse",
      "web referrer": "A website",
      "app referrer": "Another app",
      "app clip": "An App Clip",
      "institutional purchase": "Bought by an organization",
      unavailable: "Unknown",
    } as Record<string, string>,

    countriesHeading: "Where people download it",
    countriesCaption: "First-time downloads by App Store country, from the sales reports.",
    countriesEmpty: "No first-time downloads in this period.",
    countriesOf: (n: number) => `of ${n} first-time downloads`,
    countriesRest: (n: number) => `${n} more ${n === 1 ? "country" : "countries"}`,

    crashesHeading: "Crashes",
    crashesCaption:
      "Crashes Apple collected, by app version. Apple leaves them out until at least five people are behind them, so a small app can show none.",
    crashesNone: "No crashes reported in this period.",
    crashesWaiting: "Apple hasn't delivered a crash report yet.",
    version: "Version",
    crashes: "Crashes",

    reviewsHeading: "Ratings and reviews",
    reviewsCaption: "The newest written reviews, from every App Store country. A rating with no review only counts toward the average.",
    reviewsEmpty: "No written reviews yet.",
    reviewsNeedKey: "Written reviews come from App Store Connect, which isn't connected.",
    reviewsCount: (shown: number, total: number) =>
      shown === total ? `${total} written ${total === 1 ? "review" : "reviews"}` : `The newest ${shown} of ${total} written reviews`,
    stars: (n: number) => `${n} out of 5 stars`,
    reviewMeta: (author: string, territory: string, date: string) => [author, territory, date].filter(Boolean).join(" · "),

    problem: {
      notConnected:
        "Set ASC_KEY_ID, ASC_ISSUER_ID and ASC_PRIVATE_KEY on the Vercel project, plus ASC_VENDOR_NUMBER for sales, then redeploy. web/README.md has the steps. The rating needs none of it.",
      noVendor:
        "ASC_VENDOR_NUMBER isn't set, so there are no sales reports. It's the number at the top left of Payments and Financial Reports in App Store Connect.",
      badPrivateKey: "ASC_PRIVATE_KEY isn't a readable .p8 key. Paste the whole file, BEGIN and END lines included.",
      badKey:
        "Apple refused the key. Check that ASC_KEY_ID, ASC_ISSUER_ID and ASC_PRIVATE_KEY all belong to the same App Store Connect API key, and that it hasn't been revoked.",
      forbidden: "The key isn't allowed to read this. It needs Sales, Finance or Admin access in App Store Connect.",
      reviewsForbidden:
        "The key isn't allowed to read reviews. Apple only lets an Admin or Customer Support key read them; the rest of this page works with Sales access.",
      badVendor: "Apple doesn't recognize ASC_VENDOR_NUMBER as this account's vendor number.",
      rateLimited: "This key has used up its App Store Connect requests for the hour. Try again later.",
      unreachable: "Couldn't reach App Store Connect. Try again in a moment.",
      storeUnreachable: "Couldn't reach the App Store for the rating. Try again in a moment.",
      reportShape: (report: string, missing: string) =>
        `Apple's ${report} report is missing columns this page reads (${missing}). Its format may have changed.`,
      other: (detail: string) => `App Store Connect answered with an error: ${detail}`,
    },
  },

  players: {
    heading: "Players",
    caption: "Everyone the game has saved. A player is a device: the game has no accounts, so a reinstall is a new player.",
    search: "Search name, Game Center name or device id",
    searchButton: "Search",
    sort: "Sort",
    sorts: { active: "Last active", time: "Most time", polynite: "Most Polynite", items: "Most items", name: "Name" },
    shows: { all: "All", named: "With a name", buyers: "Bought something" },
    show: "Show",
    player: "Player",
    polynite: "Polynite",
    owns: "Owns",
    wearing: "Wearing",
    lastActive: "Last active",
    time: "Time in game",
    timeHint: "Time with the game open, from versions after 3.4.",
    gameCenterTag: "Game Center",
    gameCenterHint: "No online name, so this is the name they go by in Game Center.",
    notRecorded: "Not recorded",
    notRecordedHint:
      "Only versions of the game after 3.4 save when they were last open. Anyone without a time hasn't opened one yet, and sorts after everyone who has.",
    nothingExtra: "Defaults only",
    noName: "No name",
    count: (shown: number, matching: number, total: number) =>
      matching === total
        ? shown === total
          ? `${total.toLocaleString("en-US")} players`
          : `The first ${shown.toLocaleString("en-US")} of ${total.toLocaleString("en-US")} players`
        : shown === matching
          ? `${matching.toLocaleString("en-US")} of ${total.toLocaleString("en-US")} players`
          : `The first ${shown.toLocaleString("en-US")} of ${matching.toLocaleString("en-US")} matching, out of ${total.toLocaleString("en-US")}`,
    noMatches: "Nobody matches that.",
    empty: "No players in the database yet.",
    showMore: "Show more",
  },

  player: {
    back: "All players",
    notFound: "There's no player saved under that device id.",
    caption:
      "Everything the game keeps about this player. Apart from when they last had it open, nothing has a date, so there's no history to show.",
    lastActive: "Last active",
    lastActiveValue: (when: string, ago: string) => `${ago} · ${when}`,
    notRecorded: "Not recorded. Only versions of the game after 3.4 save it.",
    gameCenter: "Game Center name",
    gameCenterNone: "None saved. They're not signed in, or haven't opened a version after 3.4.",
    time: "Time in game",
    timeValue: (time: string, days: number) => `${time} over ${days} ${days === 1 ? "day" : "days"}`,
    playHeading: "What they play",
    playCaption: "Every mode and menu, how often it came up and how long they stayed, since they updated to a version that records it.",
    playEmpty: "Nothing recorded. Versions of the game after 3.4 save this.",
    name: "Online name",
    noName: "None. They haven't played online.",
    device: "Device id",
    deviceHint: "Apple's identifier for this app on their device. A reinstall gets a new one, and a new, empty player.",
    polynite: "Polynite",
    wearing: "Wearing",
    shopHeading: "Shop",
    shopCaption: "Every item, and whether they have it.",
    owned: "Owned",
    notOwned: "Not owned",
    wearingNow: "Wearing",
    noShop: "They've never opened the shop, so they have the defaults and nothing else.",
    gamesHeading: "In online games",
    gamesCaption:
      "Games and lobbies that list their online name. Online games know players by name only, so anyone else with the same name shows here too.",
    gamesNone: "Not in any game or lobby right now.",
    gamesNoName: "They have no online name, so they can't be in an online game.",
  },

  games: {
    heading: "Online games",
    caption: "Every online game in the database right now: being played, waiting in a lobby, or left behind.",
    playing: "Being played",
    lobbies: "Lobbies open",
    players: "Players in them",
    leftBehind: "Left behind",
    leftBehindHint:
      "Games still in the database with nobody in them. The game cleans up after itself only when the host leaves the normal way.",
    queue: (n: number) => `${n} public ${n === 1 ? "lobby" : "lobbies"} looking for players`,
    liveHeading: "Being played and waiting",
    liveCaption:
      "Games with at least one player still in them. From versions after 3.4 the server marks a player gone the moment their app closes or drops offline; an older version can still leave a seat behind.",
    liveEmpty: "Nobody is in an online game right now.",
    code: "Code",
    status: "Status",
    statusPlaying: "Playing",
    statusLobby: "In the lobby",
    statusLeft: "Left behind",
    mode: "Mode",
    map: "Map",
    host: "Host",
    who: "Players",
    left: (n: number) => `${n} left`,
    kicked: (n: number) => `${n} kicked`,
    publicTag: "Public",
    unknown: "Not set",
    modesHeading: "Modes picked",
    modesCaption:
      "Every game in the database, left-behind ones included, by mode. They pile up, so this is the closest thing to a history of what people play.",
    mapsHeading: "Maps picked",
    mapsCaption: "The same games, by map.",
    ofGames: (n: number) => `of ${n.toLocaleString("en-US")} games`,
    empty: "No online games in the database.",
    leftHeading: "Left behind",
    leftCaption: "Games nobody is in. Nothing reads them, so they're only taking up space.",
    showLeft: (n: number) => `Show all ${n.toLocaleString("en-US")}`,
    leftNone: "Nothing left behind.",
  },

  problem: {
    heading: "The dashboard can't load its data",
    noKey:
      "FIREBASE_SERVICE_ACCOUNT isn't set on the server. It's a service account key from the Firebase console; web/README.md has the steps.",
    badServiceAccount:
      "FIREBASE_SERVICE_ACCOUNT isn't a readable service account key. Paste the whole JSON file Firebase downloaded, braces included.",
    badKey:
      "Google refused the service account key. It may have been deleted in the Firebase console; make a new one and replace FIREBASE_SERVICE_ACCOUNT.",
    forbidden:
      "Firebase refused the service account. It needs access to the Realtime Database: use the firebase-adminsdk account the Firebase console makes, or give this one the Firebase Realtime Database Viewer role.",
    badDatabase:
      "There's no Realtime Database at FIREBASE_DATABASE_URL. Leave it unset to use the live one.",
    unreachable: "Couldn't reach Firebase. Try again in a moment.",
    other: (detail: string) => `Firebase answered with an error: ${detail}`,
  },

  loading: "Loading",
} as const;
