# ghostpilots.dhrooby.com

The site behind Ghost Pilots' admin dashboard. It exists for `/admin`; the
root is one page pointing at the App Store, so the domain isn't a 404 for
anyone who trims the dashboard's address back to it.

It's a small Next.js app on Vercel, built from Whensday's site (the Whensday
repo, `w.dhrooby.com`), which was built from FitPals' (the SweatHearts repo,
`fitpals.dhrooby.com`). Like them it lives on its own subdomain of
`dhrooby.com`, as its own Vercel project, so it can't break the personal site
on the apex or either of the other two.

## Routes

- `/` - the game's name, one line about it, and a link to the App Store.
- `/admin` - the admin dashboard, behind a password. See below.

## The admin dashboard

`/admin` is where the game's Firebase data and Apple's numbers are read back.
It's the third of three: FitPals' at `fitpals.dhrooby.com/admin` and
Whensday's at `w.dhrooby.com/admin` have the same layout and sidebar, and the
switcher at the top of each jumps between them. `app/admin/dashboards.ts`
lists all three, and its copies in the other two repos have to match it apart
from `CURRENT`. Four tabs:

- **Overview** - how many players there are and how many picked an online
  name, who's in an online game, how much Polynite is out there, players and
  minutes a day, what people play and for how long, who owns which shop item,
  and how balances spread out.
- **App Store** - what Apple reports: downloads, where they came from and
  which countries, the store page, crashes, ratings and reviews. The same tab
  as the other two dashboards; see below.
- **Players** - everyone, most recently active first, searchable by online
  name, Game Center name or device id, with a page each for their balance,
  their shop, what they play and any online game they're in.
- **Online games** - what's being played and waiting right now, which modes
  and maps people pick, and the games left behind in the database.

It's server-rendered from the game's Firebase Realtime Database
(`ghostpilots-d199f`), read over its REST API by `app/admin/lib/firebase.ts`
with a service account. The key stays on the server, and the browser only ever
sees finished HTML. Nothing on the dashboard writes to the database.

### What the game keeps, and what it doesn't

Everything comes from three nodes the app writes (`app/admin/lib/data.ts` has
the detail):

- `Users/<device>` - the Polynite balance and the shop (`ShopStuff`, a JSON
  string). Written the first time an install opens the game.
- `systemID/<device>` - the online name, once they've picked one.
- `Games/<code>` - each online game or lobby, and `Games/LFG` for the public
  ones looking for players.

So a player is a device (`identifierForVendor`), and a reinstall is a new,
empty player. Up to 3.4 nothing carried a date. Versions after it also write,
under `Users/<device>` (`APBOv2/Firebase/DataPusher.swift`):

- `LastSeen` - a server timestamp, each time the game opens or comes back to
  the front. The Players tab sorts by it.
- `GameCenter` - their Game Center name, once signed in, shown for anyone
  without an online name and tagged as such.
- `Play/<scene>/plays` and `/seconds` - how often each scene came on screen
  and for how long, keyed by its class name (`labels.ts` names them).
- `Days/<yyyy-MM-dd>` - seconds the game was open each UTC day, which the
  Overview's "Day by day" charts.

Until players update, those read "Not recorded" and the sections that need
them say so. "In an online game" is as the database has it; someone whose app
died mid-lobby still shows, since lobbies carry no times. Games nobody is left
in are counted separately, as left behind.

### Turning it on

It stays off, saying so on `/admin/login`, until these are set on the Vercel
project (Settings, then Environment Variables, for Production, marked
Sensitive):

| Variable | What |
| --- | --- |
| `ADMIN_PASSWORD` | The one password. At least 12 characters, or the dashboard stays off. `openssl rand -base64 24` makes a good one. Use a different one from the other two dashboards'. |
| `FIREBASE_SERVICE_ACCOUNT` | A service account key: the whole JSON file Google downloads, braces included (base64 of it works too). |
| `FIREBASE_DATABASE_URL` | Optional. Defaults to the live database. |

Then redeploy. Until the key is there, the pages say so instead of showing
numbers.

Which service account to give it is a trade, much like the App Store key:

- **Read-only** is the better thing to leave on Vercel. In the Google Cloud
  console for `ghostpilots-d199f`: IAM and Admin, then Service Accounts, then
  Create. Name it `admin-dashboard`, give it **Firebase Realtime Database
  Viewer**, then Keys, Add key, JSON.
- **The Firebase Admin SDK account** is two clicks: Firebase console, Project
  settings, Service accounts, Generate new private key. But it can read and
  write everything in the project, sitting on a public repo's Vercel project.

If the dashboard says Firebase refused the account, the account can't read
the database: check its role, or fall back to the Admin SDK one. A key deleted
in the console signs the dashboard out of Firebase at once, which is the way
to revoke it.

Four things about it are worth knowing:

- **One password, no accounts.** The session is an HttpOnly cookie scoped to
  `/admin`, holding an expiry and an HMAC keyed off the password, so changing
  `ADMIN_PASSWORD` signs every browser out. Every read checks the session
  itself (`read` in `app/admin/lib/firebase.ts`), not just the page around it.
  It's a separate password and cookie from the other two dashboards', so the
  switcher asks you to sign in on each once.
- **It reads the whole player list.** Every install is a player, so the list
  can be long. It's downloaded once a minute at most, shared between tabs, and
  cut down on the server: the Players tab sends the browser a hundred rows at a
  time.
- **Online names aren't unique.** The game never checks, and online games list
  players by name, so a player's page shows every game listing their name.
- **It never writes.** Changing a balance or clearing left-behind games would
  happen under people mid-game, with no record of when. If that's ever wanted,
  it belongs behind a confirm step like the other dashboards' one write.

### The App Store tab

`/admin/app-store` is what Apple knows that the database can't: downloads,
proceeds and purchases from Sales and Trends; impressions, page views, where
downloads came from, and crashes from App Analytics; written reviews; and the
US rating. It reads App Store Connect directly with an API key, from
`app/admin/lib/appstore.ts`. That file is the same in every dashboard's repo;
which app it reads comes from `dashboards.ts`. Nothing on the tab comes from
the database or is about any one account, and the reviews are what the store
already shows in public.

What Apple has finished with is cached for good (`unstable_cache`, which on
Vercel outlives a deploy): a past day's sales never change, and neither does an
analytics delivery. So a page load only asks Apple for the newest day or two.

It stays off, saying so on the tab, until these are set on the Vercel project
(Production, marked Sensitive). The rating needs none of them.

| Variable | What |
| --- | --- |
| `ASC_KEY_ID` | The key's ID. App Store Connect: Users and Access, then Integrations, then App Store Connect API, then Team Keys. |
| `ASC_ISSUER_ID` | The Issuer ID at the top of that page. |
| `ASC_PRIVATE_KEY` | The whole `AuthKey_<KEY_ID>.p8`, BEGIN and END lines included. Apple lets you download it once. |
| `ASC_VENDOR_NUMBER` | The number at the top left of Payments and Financial Reports. Only the sales reports need it. Every app on the account shares it. |

Make one key for every dashboard, named `admin-dashboard`, so it can be
revoked without touching fastlane, and set the same four values on each
dashboard's Vercel project. Which access to give it is a trade:

- **Sales** reads everything on the tab except written reviews, and can't
  change any app. Apple only lets Admin and Customer Support keys read
  reviews, so that section says the key can't.
- **Admin** reads everything, but it's also a key that can change the listing,
  prices and builds, sitting on Vercel next to the database key. fastlane's
  `fastlane-admin` key (SweatHearts, `fastlane/.env`) works as it is.

Worth knowing:

- **Days are Apple's, on Pacific time, and finish at 5am the morning after.**
  Apple posts a day region by region and the Americas come last, so before 5am
  a day can read "no sales" that only means the US isn't in. Until then the tab
  ends on the day before yesterday.
- **Proceeds are never converted.** Apple pays out in each storefront's own
  currency. The tab leads with dollars and lists the rest beside them.
- **App Analytics has to be asked for**, once per app, by an Admin key. All
  three apps were asked on 2026-11-17, with a one-time snapshot of their
  history.
  Apple keeps each delivery for 35 days, so the store page and crashes go back
  about five weeks while sales go back a year. Apple also stops a request that
  nothing collects for a long while. The tab says so if it happens, and this
  asks again:

  ```bash
  ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_PATH=~/.appstoreconnect/private_keys/AuthKey_….p8 \
    node scripts/request-app-analytics.mjs <app id> [--history]
  ```

  The app ids are in `dashboards.ts`.
- **There's no test-data switch.** Sandbox purchases and TestFlight installs
  never reach Apple's reports.
- **Crashes can stay empty for a small app.** Apple leaves crash counts out until at
  least five people are behind them.

Ghost Pilots' entry in `dashboards.ts` is the original 2020 listing,
`1538606743` (bundle `edu.astroparty`, SKU `vincentanddhruv`), the one this
repo ships. The account also has `6784017006`, "Ghost Pilots - Space Game",
from a bundle id change that was later undone; nothing ships to it. The game
sells nothing, so like Whensday's the tab shows updates where FitPals' shows
proceeds.

### Locally

Put `ADMIN_PASSWORD` and `FIREBASE_SERVICE_ACCOUNT` in `web/.env.local`
(gitignored by `web/.gitignore`), the `ASC_*` ones too if you want the App
Store tab, and run `npm run dev`. With the live project's key that's live
data, so treat the file like the key it holds.

## Local

```bash
npm install
npm run dev
```

## Deploy

The site is the Vercel project `ghostpilots-web` (root directory `web`),
connected to this repo, with **`firebase` as its production branch**: that's
where the game's work happens, and `master` is far behind it. Every push to
`firebase` deploys it. Nothing to run by hand.

`ghostpilots.dhrooby.com` is attached to that project. Its DNS lives in
Namecheap (Advanced DNS on `dhrooby.com`), as one record pointing at the
target Vercel gave the project:

```
CNAME   ghostpilots   ->   b3c455362ac57b9a.vercel-dns-017.com.
```

`npx vercel domains verify ghostpilots.dhrooby.com` prints the record again if
it ever needs re-adding. Leave the apex, `www`, `w` and `fitpals` records
alone.

Moving to another domain means changing `url` in all three copies of
`dashboards.ts`, this project's Vercel domain, and this file.
