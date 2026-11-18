import { createPrivateKey, sign, type KeyObject } from "node:crypto";
import { gunzipSync } from "node:zlib";
import { unstable_cache } from "next/cache";
import { CURRENT_DASHBOARD } from "../dashboards";
import { AdminStrings } from "../strings";
import { DashboardError } from "./data";
import { requireAdmin } from "./session";

/// The App Store tab's reads: what Apple knows about the app that the
/// database can't. Four sources, none of them ours.
///
/// - **Sales and Trends** (`/v1/salesReports`). One file a day for the whole
///   account (every app, every download, purchase and refund), cut down here
///   to this app. Apple keeps a year of them.
/// - **App Analytics** (`/v1/analyticsReportRequests` and what hangs off it).
///   The store page's impressions and views, where downloads came from, and
///   crashes. Apple only makes these once an Admin key has asked, once per app
///   (web/README.md has how), and keeps each delivery for 35 days.
/// - **Customer reviews** (`/v1/apps/{id}/customerReviews`). Written reviews
///   from every country. Only an Admin or Customer Support key may read them;
///   with any other, the section says so and the rest of the tab carries on.
///   Not the store's public reviews feed: that one is US only, and it served
///   an empty list for every app on the afternoon this was written.
/// - **The public App Store lookup**, the one the app's own update check
///   reads, for the US rating and the version on sale. No key.
///
/// Anything Apple has finished with is cached for good: a past day's sales
/// file never changes, and neither does an analytics delivery once made.
/// `unstable_cache` keeps them across requests and deploys, so a page load
/// only asks Apple for the newest day or two and anything it hasn't seen.
/// Bump `VERSION` when a change here changes what a cached entry holds.
///
/// This file is the same in every dashboard's repo (SweatHearts, Whensday and
/// Ghost-Pilots). Which app it reads comes from `dashboards.ts`.

const VERSION = "v1";
const APP = CURRENT_DASHBOARD.appStore;
const t = AdminStrings.appStore.problem;

const HOUR = 60 * 60;
const API = "https://api.appstoreconnect.apple.com";

// ---------------------------------------------------------------------------
// The key
// ---------------------------------------------------------------------------

type Credentials = { keyId: string; issuerId: string; privateKey: string };

function credentials(): Credentials | null {
  const keyId = process.env.ASC_KEY_ID?.trim();
  const issuerId = process.env.ASC_ISSUER_ID?.trim();
  const privateKey = process.env.ASC_PRIVATE_KEY?.trim();
  return keyId && issuerId && privateKey ? { keyId, issuerId, privateKey } : null;
}

/// Whether there's a key to ask Apple with. The tab still shows ratings and
/// reviews without one, since those come from the public store.
export function isConnected(): boolean {
  return credentials() !== null;
}

/// The .p8 however it was pasted: whole, with its line breaks escaped as
/// `\n`, or only the base64 between the BEGIN and END lines.
function readKey(value: string): KeyObject {
  const text = value.replace(/\\n/g, "\n");
  const pem = text.includes("-----BEGIN")
    ? text
    : `-----BEGIN PRIVATE KEY-----\n${text.replace(/\s+/g, "").replace(/(.{64})/g, "$1\n")}\n-----END PRIVATE KEY-----\n`;
  try {
    return createPrivateKey(pem);
  } catch {
    throw new DashboardError(t.badPrivateKey);
  }
}

let minted: { token: string; keyId: string; until: number } | null = null;

/// An ES256 JWT for the App Store Connect API. Apple refuses one that lives
/// longer than twenty minutes; these are minted for twenty and reused for
/// fifteen.
function bearer(c: Credentials): string {
  if (minted && minted.keyId === c.keyId && minted.until > Date.now()) return minted.token;
  const now = Math.floor(Date.now() / 1000);
  const part = (value: object) => Buffer.from(JSON.stringify(value)).toString("base64url");
  const unsigned = `${part({ alg: "ES256", kid: c.keyId, typ: "JWT" })}.${part({
    iss: c.issuerId,
    iat: now,
    exp: now + 20 * 60,
    aud: "appstoreconnect-v1",
  })}`;
  const signature = sign("sha256", Buffer.from(unsigned), {
    key: readKey(c.privateKey),
    dsaEncoding: "ieee-p1363",
  }).toString("base64url");
  minted = { token: `${unsigned}.${signature}`, keyId: c.keyId, until: Date.now() + 15 * 60 * 1000 };
  return minted.token;
}

// ---------------------------------------------------------------------------
// Talking to Apple
// ---------------------------------------------------------------------------

type AppleError = { detail: string; parameter: string | null };

async function appleError(response: Response): Promise<AppleError> {
  const text = await response.text();
  try {
    const first = (JSON.parse(text) as { errors?: { detail?: string; title?: string; source?: { parameter?: string } }[] })
      .errors?.[0];
    return { detail: first?.detail ?? first?.title ?? text.slice(0, 200), parameter: first?.source?.parameter ?? null };
  } catch {
    return { detail: text.slice(0, 200), parameter: null };
  }
}

/// One call to the App Store Connect API, with Apple's refusals put into
/// words. A 404 comes back to the caller, because for a sales report it means
/// "nothing sold" or "not posted yet" rather than a mistake. `forbidden` is
/// what a 403 means for this call: which roles may make it differs by call.
async function asc(pathOrUrl: string, forbidden: string = t.forbidden): Promise<Response> {
  const c = credentials();
  if (!c) throw new DashboardError(t.notConnected);

  let response: Response;
  try {
    response = await fetch(pathOrUrl.startsWith("https://") ? pathOrUrl : `${API}${pathOrUrl}`, {
      headers: { Authorization: `Bearer ${bearer(c)}` },
      cache: "no-store",
    });
  } catch {
    throw new DashboardError(t.unreachable);
  }
  if (response.ok || response.status === 404) return response;

  const error = await appleError(response);
  if (response.status === 401) throw new DashboardError(t.badKey);
  if (response.status === 403) throw new DashboardError(forbidden);
  if (response.status === 429) throw new DashboardError(t.rateLimited);
  if (error.parameter === "filter[vendorNumber]") throw new DashboardError(t.badVendor);
  throw new DashboardError(t.other(`${response.status} ${error.detail}`));
}

/// Every page of a list, following Apple's `next` links.
async function list<T>(path: string): Promise<T[]> {
  const items: T[] = [];
  let next: string | undefined = path;
  while (next) {
    const response = await asc(next);
    if (response.status === 404) break;
    const page = (await response.json()) as { data: T[]; links?: { next?: string } };
    items.push(...page.data);
    next = page.links?.next;
  }
  return items;
}

/// A tab-separated report, gzipped or not, as rows keyed by lower-cased column
/// name. Apple says to go by names rather than positions, and that values
/// aren't case-sensitive.
function readTable(bytes: ArrayBuffer): { columns: string[]; rows: Record<string, string>[] } {
  const raw = Buffer.from(bytes);
  const text = (raw[0] === 0x1f && raw[1] === 0x8b ? gunzipSync(raw) : raw).toString("utf8");
  const lines = text.split(/\r?\n/).filter((line) => line.trim() !== "");
  if (lines.length === 0) return { columns: [], rows: [] };
  const cell = (value: string) => value.replace(/^﻿/, "").trim().replace(/^"(.*)"$/, "$1").trim();
  const columns = lines[0].split("\t").map((name) => cell(name).toLowerCase());
  const rows = lines.slice(1).map((line) => {
    const cells = line.split("\t");
    return Object.fromEntries(columns.map((name, i) => [name, cell(cells[i] ?? "")]));
  });
  return { columns, rows };
}

function requireColumns(report: string, columns: string[], needed: string[]) {
  const missing = needed.filter((name) => !columns.includes(name));
  if (missing.length > 0) throw new DashboardError(t.reportShape(report, missing.join(", ")));
}

// ---------------------------------------------------------------------------
// Days
// ---------------------------------------------------------------------------

/// The date and hour in Pacific time, which Apple's reports go by.
function pacificNow(): { day: string; hour: number } {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: "America/Los_Angeles",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    hourCycle: "h23",
  }).formatToParts(new Date());
  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? "";
  return { day: `${get("year")}-${get("month")}-${get("day")}`, hour: Number(get("hour")) };
}

/// A `yyyy-MM-dd` day moved by whole days. Noon UTC, so no zone can tip it.
function shift(day: string, by: number): string {
  const date = new Date(`${day}T12:00:00Z`);
  date.setUTCDate(date.getUTCDate() + by);
  return date.toISOString().slice(0, 10);
}

/// The newest day Apple has finished: yesterday from 5am Pacific, the day
/// before until then. Apple posts a day region by region and the Americas
/// come last, at 5am, so before that a day can read "no sales" that only
/// means the US isn't in yet.
function newestDay(): string {
  const now = pacificNow();
  return shift(now.day, now.hour >= 5 ? -1 : -2);
}

/// The `count` days ending with the newest one Apple has finished, oldest
/// first.
function periodDays(count: number): string[] {
  const newest = newestDay();
  return Array.from({ length: count }, (_, i) => shift(newest, i - count + 1));
}

/// A report's date, as `yyyy-MM-dd` whichever way Apple wrote it.
function isoDay(value: string | undefined): string | null {
  const iso = value?.match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (iso) return `${iso[1]}-${iso[2]}-${iso[3]}`;
  const us = value?.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (us) return `${us[3]}-${us[1].padStart(2, "0")}-${us[2].padStart(2, "0")}`;
  return null;
}

// ---------------------------------------------------------------------------
// Sales and Trends
// ---------------------------------------------------------------------------

/// One day of this app's sales, as Apple's daily summary report has it.
/// Counts are net: a refund is a row of minus one.
export type SalesDay = {
  day: string;
  /// Someone getting the app on an Apple Account that never had it.
  downloads: number;
  redownloads: number;
  updates: number;
  /// In-app purchases that cost nothing: a free trial or offer starting.
  trials: number;
  /// Paid in-app purchases that aren't renewals: new subscriptions, one-offs.
  purchases: number;
  renewals: number;
  /// What Apple pays out after its commission, in each storefront's currency.
  proceeds: Record<string, number>;
  /// First-time downloads by App Store country.
  countries: Record<string, number>;
};

export type Sales = {
  /// Every day in the period Apple has posted, oldest first. A day with
  /// nothing sold is here as zeros.
  days: SalesDay[];
  /// The newest day Apple has posted, or null if it hasn't posted any of them.
  through: string | null;
  /// How many days of the period Apple hasn't posted yet.
  waiting: number;
};

/// Apple's product type identifiers. Anything starting IA or FI is an in-app
/// purchase.
const FIRST_TIME = new Set(["1", "1F", "1T", "F1", "1E", "1EP", "1EU", "1-B", "F1-B"]);
const REDOWNLOAD = new Set(["3", "3F", "3T", "F3"]);
const UPDATE = new Set(["7", "7F", "7T", "F7"]);

/// Thrown, never returned, for a day Apple hasn't posted yet, so the cache
/// keeps nothing and the next load asks again.
const NOT_YET = "asc-not-posted-yet";

async function fetchSalesDay(day: string, appId: string, sku: string, vendor: string): Promise<SalesDay> {
  const query = new URLSearchParams({
    "filter[frequency]": "DAILY",
    "filter[reportType]": "SALES",
    "filter[reportSubType]": "SUMMARY",
    "filter[version]": "1_0",
    "filter[reportDate]": day,
    "filter[vendorNumber]": vendor,
  });
  const response = await asc(`/v1/salesReports?${query}`);

  const sum: SalesDay = {
    day,
    downloads: 0,
    redownloads: 0,
    updates: 0,
    trials: 0,
    purchases: 0,
    renewals: 0,
    proceeds: {},
    countries: {},
  };

  if (response.status === 404) {
    // Two different 404s: "There were no sales for the date specified" is a
    // real zero, anything else ("Report is not available yet") isn't.
    if (/no sales/i.test((await appleError(response)).detail)) return sum;
    throw new Error(NOT_YET);
  }

  const { columns, rows } = readTable(await response.arrayBuffer());
  requireColumns("Sales", columns, ["product type identifier", "units", "apple identifier", "parent identifier"]);

  for (const row of rows) {
    const type = row["product type identifier"];
    const units = Number(row.units) || 0;
    const inApp = /^(IA|FI)/i.test(type) && row["parent identifier"] === sku;
    if (!inApp && row["apple identifier"] !== appId) continue; // another app on the account

    const currency = row["currency of proceeds"];
    const proceeds = units * (Number(row["developer proceeds"]) || 0);
    if (currency && proceeds !== 0) {
      sum.proceeds[currency] = Math.round(((sum.proceeds[currency] ?? 0) + proceeds) * 100) / 100;
    }

    if (inApp) {
      if ((Number(row["customer price"]) || 0) === 0) sum.trials += units;
      else if (/renewal/i.test(row.subscription ?? "")) sum.renewals += units;
      else sum.purchases += units;
    } else if (FIRST_TIME.has(type)) {
      sum.downloads += units;
      const country = row["country code"] || "?";
      sum.countries[country] = (sum.countries[country] ?? 0) + units;
    } else if (REDOWNLOAD.has(type)) {
      sum.redownloads += units;
    } else if (UPDATE.has(type)) {
      sum.updates += units;
    }
  }
  return sum;
}

/// A day is asked about hourly for its first few days, in case Apple posts it
/// in pieces, then kept for good.
const salesDayRecent = unstable_cache(fetchSalesDay, ["asc-sales-day", "recent", VERSION], { revalidate: HOUR });
const salesDaySettled = unstable_cache(fetchSalesDay, ["asc-sales-day", "settled", VERSION], { revalidate: false });

/// The last `count` days of sales that Apple has finished.
export async function getSales(count: number): Promise<Sales> {
  await requireAdmin();
  if (!credentials()) throw new DashboardError(t.notConnected);
  const vendor = process.env.ASC_VENDOR_NUMBER?.trim();
  if (!vendor) throw new DashboardError(t.noVendor);

  const settledBefore = shift(pacificNow().day, -3);
  const days = await Promise.all(
    periodDays(count).map(async (day) => {
      const read = day < settledBefore ? salesDaySettled : salesDayRecent;
      try {
        return await read(day, APP.id, APP.sku, vendor);
      } catch (error) {
        if (error instanceof Error && error.message === NOT_YET) return null;
        throw error;
      }
    }),
  );
  const posted = days.filter((day): day is SalesDay => day !== null);
  return { days: posted, through: posted.at(-1)?.day ?? null, waiting: days.length - posted.length };
}

// ---------------------------------------------------------------------------
// App Analytics
// ---------------------------------------------------------------------------

/// The three analytics reports the tab reads, by the names Apple lists them
/// under, and what each one boils down to per day. Each summary is a flat map
/// of numbers, small enough to cache whole:
///
/// - engagement: `impressions` and `pageViews`
/// - downloads: first-time downloads by source type ("app store search", …)
/// - crashes: crashes by app version
type Kind = "engagement" | "downloads" | "crashes";
type DaySummary = Record<string, number>;

const REPORTS: Record<Kind, { name: string; needs: string[]; add: (row: Record<string, string>, into: DaySummary) => void }> = {
  engagement: {
    name: "App Store Discovery and Engagement Standard",
    needs: ["date", "event", "counts"],
    add(row, into) {
      const event = row.event.toLowerCase();
      const key = event === "impression" ? "impressions" : event === "page view" ? "pageViews" : null;
      if (key) into[key] = (into[key] ?? 0) + (Number(row.counts) || 0);
    },
  },
  downloads: {
    name: "App Downloads Standard",
    needs: ["date", "download type", "source type", "counts"],
    add(row, into) {
      if (row["download type"].toLowerCase() !== "first-time download") return;
      const source = row["source type"].toLowerCase() || "unavailable";
      into[source] = (into[source] ?? 0) + (Number(row.counts) || 0);
    },
  },
  crashes: {
    name: "App Crashes",
    needs: ["date", "app version", "crashes"],
    add(row, into) {
      const version = row["app version"] || "?";
      into[version] = (into[version] ?? 0) + (Number(row.crashes) || 0);
    },
  },
};

const KINDS: readonly Kind[] = ["engagement", "downloads", "crashes"];

type ReportRequest = { id: string; ongoing: boolean; stopped: boolean };

async function fetchRequests(appId: string): Promise<ReportRequest[]> {
  const requests = await list<{ id: string; attributes: { accessType: string; stoppedDueToInactivity: boolean } }>(
    `/v1/apps/${appId}/analyticsReportRequests`,
  );
  return requests.map((r) => ({
    id: r.id,
    ongoing: r.attributes.accessType === "ONGOING",
    stopped: r.attributes.stoppedDueToInactivity,
  }));
}

async function fetchReportId(requestId: string, name: string): Promise<string | null> {
  const reports = await list<{ id: string; attributes: { name: string } }>(
    `/v1/analyticsReportRequests/${requestId}/reports?${new URLSearchParams({ "filter[name]": name })}`,
  );
  return reports.find((r) => r.attributes.name.trim() === name)?.id ?? null;
}

type Instance = { id: string; processed: string };

async function fetchInstances(reportId: string): Promise<Instance[]> {
  const instances = await list<{ id: string; attributes: { processingDate: string } }>(
    `/v1/analyticsReports/${reportId}/instances?filter[granularity]=DAILY&limit=200`,
  );
  return instances.map((i) => ({ id: i.id, processed: i.attributes.processingDate }));
}

/// One delivery, summed by the date each row is about. An instance holds one
/// or more files (segments), and one file can hold several dates: the day it
/// was made for, plus late rows for earlier ones.
async function fetchInstance(instanceId: string, kind: Kind): Promise<Record<string, DaySummary>> {
  const report = REPORTS[kind];
  const segments = await list<{ attributes: { url: string } }>(`/v1/analyticsReportInstances/${instanceId}/segments`);
  const byDay: Record<string, DaySummary> = {};
  for (const segment of segments) {
    let response: Response;
    try {
      // A pre-signed link, so no key goes with it.
      response = await fetch(segment.attributes.url, { cache: "no-store" });
    } catch {
      throw new DashboardError(t.unreachable);
    }
    if (!response.ok) throw new DashboardError(t.other(`${response.status} downloading ${report.name}`));
    const { columns, rows } = readTable(await response.arrayBuffer());
    if (columns.length > 0) requireColumns(report.name, columns, report.needs);
    for (const row of rows) {
      const day = isoDay(row.date);
      if (day) report.add(row, (byDay[day] ??= {}));
    }
  }
  return byDay;
}

const requestsCached = unstable_cache(fetchRequests, ["asc-analytics-requests", VERSION], { revalidate: HOUR });
const reportIdCached = unstable_cache(fetchReportId, ["asc-analytics-report", VERSION], { revalidate: 24 * HOUR });
const instancesCached = unstable_cache(fetchInstances, ["asc-analytics-instances", VERSION], { revalidate: HOUR });
const instanceCached = unstable_cache(fetchInstance, ["asc-analytics-instance", VERSION], { revalidate: false });

/// One report's days from `first` on, and whether Apple has delivered it at
/// all.
///
/// Apple's rule for overlapping deliveries: a later instance replaces an
/// earlier one for any date both cover, and a date's rows are never added up
/// across instances. So each date is taken whole from the newest instance
/// that has it, the ongoing request winning a tie with the one-off history.
/// An instance made before `first` can't hold a date from `first` on.
async function analyticsDays(kind: Kind, requests: ReportRequest[], first: string) {
  const perRequest = await Promise.all(
    requests.map(async (request) => {
      const reportId = await reportIdCached(request.id, REPORTS[kind].name);
      if (!reportId) return [];
      return (await instancesCached(reportId)).map((instance) => ({ ...instance, ongoing: request.ongoing }));
    }),
  );
  const instances = perRequest.flat();
  const newestFirst = instances
    .filter((instance) => instance.processed >= first)
    .sort((a, b) => b.processed.localeCompare(a.processed) || Number(b.ongoing) - Number(a.ongoing));
  const summaries = await Promise.all(newestFirst.map((instance) => instanceCached(instance.id, kind)));

  const days: Record<string, DaySummary> = {};
  for (const summary of summaries) {
    for (const [day, values] of Object.entries(summary)) {
      if (day >= first && !(day in days)) days[day] = values;
    }
  }
  return { delivered: instances.length > 0, days };
}

export type StoreDay = { day: string; impressions: number; pageViews: number };

export type StoreAnalytics =
  /// Nobody has asked Apple for App Analytics on this app.
  | { state: "off" }
  /// Asked, and Apple hasn't delivered anything yet.
  | { state: "preparing" }
  /// Apple stopped the request for want of anyone collecting it, and nothing
  /// it delivered before is still there.
  | { state: "stopped" }
  | {
      state: "ready";
      /// The request has stopped: what's here is all there'll be until
      /// someone asks again.
      stopped: boolean;
      /// The run of days in the period the store reports cover, oldest first.
      /// A day inside the run with no rows is a zero; days before it are past
      /// what Apple keeps, days after it aren't delivered yet.
      days: StoreDay[];
      /// First-time downloads in the period by source type.
      sources: Record<string, number>;
      /// Crashes in the period by app version.
      crashes: Record<string, number>;
      /// Whether any crash report has arrived, to tell "none" from "not yet".
      crashReports: boolean;
    };

function total(days: Record<string, DaySummary>, period: Set<string>): DaySummary {
  const sum: DaySummary = {};
  for (const [day, values] of Object.entries(days)) {
    if (!period.has(day)) continue;
    for (const [key, n] of Object.entries(values)) sum[key] = (sum[key] ?? 0) + n;
  }
  return sum;
}

/// The store page and crashes over the same days as the sales.
export async function getStoreAnalytics(count: number): Promise<StoreAnalytics> {
  await requireAdmin();
  if (!credentials()) throw new DashboardError(t.notConnected);

  const period = periodDays(count);
  const requests = await requestsCached(APP.id);
  if (requests.length === 0) return { state: "off" };
  const stopped = !requests.some((r) => r.ongoing && !r.stopped);

  const [engagement, downloads, crashes] = await Promise.all(
    KINDS.map((kind) => analyticsDays(kind, requests, period[0])),
  );
  if (!engagement.delivered && !downloads.delivered && !crashes.delivered) {
    return { state: stopped ? "stopped" : "preparing" };
  }

  const covered = period.filter((day) => day in engagement.days);
  const run = covered.length > 0 ? period.slice(period.indexOf(covered[0]), period.indexOf(covered.at(-1)!) + 1) : [];
  const inPeriod = new Set(period);

  return {
    state: "ready",
    stopped,
    days: run.map((day) => ({
      day,
      impressions: engagement.days[day]?.impressions ?? 0,
      pageViews: engagement.days[day]?.pageViews ?? 0,
    })),
    sources: total(downloads.days, inPeriod),
    crashes: total(crashes.days, inPeriod),
    crashReports: crashes.delivered,
  };
}

// ---------------------------------------------------------------------------
// Ratings and reviews
// ---------------------------------------------------------------------------

export type Rating = {
  /// 0 to 5, and 0 when nobody has rated it.
  average: number;
  count: number;
  /// The version on sale, and when it went out.
  version: string | null;
  released: string | null;
};

export type Review = {
  id: string;
  rating: number;
  title: string;
  body: string;
  author: string;
  /// Apple's three-letter code for the App Store it was left on: "USA".
  territory: string;
  at: string;
};

export type ReviewList = {
  /// The newest, newest first.
  newest: Review[];
  /// Every written review the app has ever had.
  total: number;
};

async function fetchRating(appId: string): Promise<Rating | null> {
  let response: Response;
  try {
    response = await fetch(`https://itunes.apple.com/lookup?id=${appId}&country=us`, { cache: "no-store" });
  } catch {
    throw new DashboardError(t.storeUnreachable);
  }
  if (!response.ok) throw new DashboardError(t.storeUnreachable);
  const body = (await response.json().catch(() => ({}))) as {
    results?: { averageUserRating?: number; userRatingCount?: number; version?: string; currentVersionReleaseDate?: string }[];
  };
  const app = body.results?.[0];
  if (!app) return null;
  return {
    average: app.averageUserRating ?? 0,
    count: app.userRatingCount ?? 0,
    version: app.version ?? null,
    released: app.currentVersionReleaseDate ?? null,
  };
}

const NEWEST_REVIEWS = 10;

async function fetchReviews(appId: string): Promise<ReviewList> {
  const query = new URLSearchParams({ sort: "-createdDate", limit: String(NEWEST_REVIEWS) });
  const response = await asc(`/v1/apps/${appId}/customerReviews?${query}`, t.reviewsForbidden);
  if (response.status === 404) return { newest: [], total: 0 };
  const page = (await response.json()) as {
    data: {
      id: string;
      attributes: { rating?: number; title?: string; body?: string; reviewerNickname?: string; territory?: string; createdDate?: string };
    }[];
    meta?: { paging?: { total?: number } };
  };
  return {
    newest: page.data.map(({ id, attributes: a }) => ({
      id,
      rating: Math.max(0, Math.min(5, a.rating ?? 0)),
      title: a.title ?? "",
      body: a.body ?? "",
      author: a.reviewerNickname ?? "",
      territory: a.territory ?? "",
      at: a.createdDate ?? "",
    })),
    total: page.meta?.paging?.total ?? page.data.length,
  };
}

const ratingCached = unstable_cache(fetchRating, ["store-rating", VERSION], { revalidate: HOUR });
const reviewsCached = unstable_cache(fetchReviews, ["asc-reviews", VERSION], { revalidate: HOUR });

/// The rating on the US App Store, and the version on sale. Needs no key.
export async function getRating(): Promise<Rating | null> {
  await requireAdmin();
  return ratingCached(APP.id);
}

/// The newest written reviews, from every country.
export async function getReviews(): Promise<ReviewList> {
  await requireAdmin();
  if (!credentials()) throw new DashboardError(t.notConnected);
  return reviewsCached(APP.id);
}
