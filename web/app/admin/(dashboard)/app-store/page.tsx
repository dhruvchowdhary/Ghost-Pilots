import { Breakdown, type BreakdownRow } from "../../components/Breakdown";
import { DailyChart } from "../../components/DailyChart";
import { Filters } from "../../components/Filters";
import { Reviews } from "../../components/Reviews";
import { KpiTile, SectionHead } from "../../components/bits";
import { CURRENT_DASHBOARD } from "../../dashboards";
import {
  getRating,
  getReviews,
  getSales,
  getStoreAnalytics,
  isConnected,
  type Rating,
  type ReviewList,
  type Sales,
  type SalesDay,
  type StoreAnalytics,
} from "../../lib/appstore";
import { attempt } from "../../lib/data";
import { countryName, formatCount, formatDate, formatDay, formatMoney } from "../../lib/format";
import { readFilters, type SearchParams } from "../../lib/params";
import { adminTimeZone, requireAdmin } from "../../lib/session";
import { AdminStrings } from "../../strings";

/// What Apple knows that the database doesn't: downloads, money, the store
/// page, crashes, ratings and reviews. Every read is `lib/appstore.ts`, and
/// each section stands on its own, so a missing vendor number or a key that
/// can't read reviews never takes the rest down with it.
///
/// The same page as Whensday's apart from this comment. FitPals' differs only
/// in its filter row, which has a "test data" switch that's turned off there;
/// Ghost Pilots, like Whensday, has none to turn off.

const SELLS = CURRENT_DASHBOARD.appStore.sells;
const t = AdminStrings.appStore;

type Result<T> = { data: T } | { problem: string };
type Totals = ReturnType<typeof totals>;

export default async function AppStorePage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  await requireAdmin();
  const filters = readFilters(await searchParams);
  const timeZone = await adminTimeZone();
  const days = filters.range.days;
  const connected = isConnected();

  const [sales, store, ratingResult, reviews] = await Promise.all([
    connected ? attempt(getSales(days)) : null,
    connected ? attempt(getStoreAnalytics(days)) : null,
    attempt(getRating()),
    connected ? attempt(getReviews()) : null,
  ]);
  const salesData = sales && "data" in sales ? sales.data : null;
  const sum = salesData ? totals(salesData.days) : null;
  const rating = "data" in ratingResult ? ratingResult.data : null;
  const live = rating?.version && rating.released ? ` ${t.live(rating.version, formatDate(rating.released, timeZone))}` : "";

  return (
    <>
      <div className="a-page-head">
        <div>
          <h1>{t.heading}</h1>
          <p>
            {t.caption}
            {live}
          </p>
        </div>
        <Filters path="/admin/app-store" filters={filters} />
      </div>

      {!connected && (
        <section className="a-card a-problem">
          <h2>{t.notConnectedHeading}</h2>
          <p>{t.problem.notConnected}</p>
        </section>
      )}

      {(sum || rating) && (
        <div className="a-kpis">
          {sum && <SalesTiles sum={sum} />}
          {rating && <RatingTile rating={rating} />}
        </div>
      )}

      {sales && "problem" in sales && <Notice message={sales.problem} />}
      {salesData && sum && <Daily sales={salesData} sum={sum} days={days} />}
      {store && <Store result={store} />}
      {sum && <Countries countries={sum.countries} />}
      {store && "data" in store && store.data.state === "ready" && (
        <Crashes crashes={store.data.crashes} delivered={store.data.crashReports} />
      )}
      <Ratings
        reviews={reviews}
        ratingProblem={"problem" in ratingResult ? ratingResult.problem : null}
        timeZone={timeZone}
      />
    </>
  );
}

function totals(days: SalesDay[]) {
  const sum = {
    downloads: 0,
    redownloads: 0,
    updates: 0,
    trials: 0,
    purchases: 0,
    renewals: 0,
    proceeds: {} as Record<string, number>,
    countries: {} as Record<string, number>,
  };
  for (const day of days) {
    sum.downloads += day.downloads;
    sum.redownloads += day.redownloads;
    sum.updates += day.updates;
    sum.trials += day.trials;
    sum.purchases += day.purchases;
    sum.renewals += day.renewals;
    for (const [currency, n] of Object.entries(day.proceeds)) sum.proceeds[currency] = (sum.proceeds[currency] ?? 0) + n;
    for (const [country, n] of Object.entries(day.countries)) sum.countries[country] = (sum.countries[country] ?? 0) + n;
  }
  return sum;
}

function Notice({ message }: { message: string }) {
  return (
    <p className="a-card a-empty a-section" role="status">
      {message}
    </p>
  );
}

const andList = new Intl.ListFormat("en", { type: "conjunction" });

/// Dollars up front when there are any, then whatever else came in, each in
/// its own currency.
function proceedsLine(proceeds: Record<string, number>) {
  const amounts = Object.entries(proceeds)
    .filter(([, n]) => Math.abs(n) >= 0.005)
    .sort(([a, x], [b, y]) => (a === "USD" ? -1 : b === "USD" ? 1 : y - x));
  const [first, ...rest] = amounts.length > 0 ? amounts : [["USD", 0] as [string, number]];
  return {
    value: formatMoney(first[1], first[0]),
    sub: rest.length > 0 ? t.proceedsPlus(andList.format(rest.map(([c, n]) => formatMoney(n, c)))) : t.proceedsSub,
  };
}

function SalesTiles({ sum }: { sum: Totals }) {
  const proceeds = proceedsLine(sum.proceeds);
  return (
    <>
      <KpiTile
        label={t.downloads}
        value={formatCount(sum.downloads)}
        sub={t.downloadsSub(sum.redownloads)}
        hint={t.downloadsHint}
      />
      {SELLS ? (
        <>
          <KpiTile label={t.proceeds} value={proceeds.value} sub={proceeds.sub} hint={t.proceedsHint} />
          <KpiTile
            label={t.paid}
            value={formatCount(sum.purchases + sum.renewals)}
            sub={t.paidSub(sum.renewals, sum.trials)}
          />
        </>
      ) : (
        <KpiTile label={t.updates} value={formatCount(sum.updates)} sub={t.updatesSub} />
      )}
    </>
  );
}

function RatingTile({ rating }: { rating: Rating }) {
  return (
    <KpiTile
      label={t.rating}
      value={rating.count > 0 ? t.ratingValue(rating.average) : t.ratingNone}
      sub={t.ratingSub(rating.count, formatCount(rating.count))}
    />
  );
}

// ---------------------------------------------------------------------------
// Day by day, from the sales reports
// ---------------------------------------------------------------------------

type Measure = "downloads" | "redownloads" | "updates" | "trials" | "paid";

const NAMES: Record<Measure, string> = {
  downloads: t.dailyDownloads,
  redownloads: t.dailyRedownloads,
  updates: t.dailyUpdates,
  trials: t.dailyTrials,
  paid: t.dailyPaid,
};

const CHARTS: readonly Measure[] = SELLS ? ["downloads", "trials", "paid"] : ["downloads", "redownloads", "updates"];
const COLUMNS: readonly Measure[] = SELLS
  ? ["downloads", "redownloads", "updates", "trials", "paid"]
  : ["downloads", "redownloads", "updates"];

function measure(day: SalesDay, key: Measure): number {
  return key === "paid" ? day.purchases + day.renewals : day[key];
}

function describe(name: string, points: { label: string; value: number }[]) {
  const peak = points.reduce((best, p) => (p.value > best.value ? p : best), points[0]);
  return peak ? t.describe(name, points.length, peak.value, peak.label) : name;
}

function Daily({ sales, sum, days }: { sales: Sales; sum: Totals; days: number }) {
  const caption = sales.days.length === 0 ? t.nothingPosted : sales.waiting > 0 && sales.through
    ? `${t.dailyCaption} ${t.through(formatDay(sales.through))}`
    : t.dailyCaption;
  const totalOf = (key: Measure) => (key === "paid" ? sum.purchases + sum.renewals : sum[key]);

  return (
    <section className="a-section">
      <SectionHead title={t.dailyHeading} caption={caption} />
      {sales.days.length > 0 && (
        <>
          <div className="a-charts">
            {CHARTS.map((key) => {
              const points = sales.days.map((day) => ({ label: formatDay(day.day), value: measure(day, key) }));
              return (
                <DailyChart
                  key={key}
                  title={NAMES[key]}
                  summary={t.inPeriod(totalOf(key), days)}
                  points={points}
                  description={describe(NAMES[key], points)}
                />
              );
            })}
          </div>
          <details className="a-details">
            <summary>{t.showTable}</summary>
            <div className="a-card">
              <div className="a-table-wrap">
                <table className="a-table">
                  <thead>
                    <tr>
                      <th scope="col">{t.tableDay}</th>
                      {COLUMNS.map((key) => (
                        <th key={key} scope="col" className="is-num">
                          {NAMES[key]}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {[...sales.days].reverse().map((day) => (
                      <tr key={day.day}>
                        <td>{formatDay(day.day, "long")}</td>
                        {COLUMNS.map((key) => (
                          <td key={key} className="is-num">
                            {measure(day, key)}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </details>
        </>
      )}
    </section>
  );
}

// ---------------------------------------------------------------------------
// The store page, from App Analytics
// ---------------------------------------------------------------------------

function Store({ result }: { result: Result<StoreAnalytics> }) {
  const head = <SectionHead title={t.storeHeading} caption={t.storeCaption} />;
  if ("problem" in result) {
    return (
      <section className="a-section">
        {head}
        <p className="a-card a-empty">{result.problem}</p>
      </section>
    );
  }

  const store = result.data;
  if (store.state !== "ready") {
    const message = { off: t.analyticsOff, preparing: t.analyticsPreparing, stopped: t.analyticsStopped }[store.state];
    return (
      <section className="a-section">
        {head}
        <p className="a-card a-empty">{message}</p>
      </section>
    );
  }

  const impressions = store.days.map((d) => ({ label: formatDay(d.day), value: d.impressions }));
  const pageViews = store.days.map((d) => ({ label: formatDay(d.day), value: d.pageViews }));
  const add = (points: { value: number }[]) => points.reduce((n, p) => n + p.value, 0);
  const first = store.days[0];
  const last = store.days.at(-1);

  const sources = Object.entries(store.sources).sort(([, a], [, b]) => b - a);
  const sourceTotal = sources.reduce((n, [, v]) => n + v, 0);
  const sourceRows: BreakdownRow[] = sources.map(([key, value]) => ({
    key,
    label: t.sources[key] ?? key.replace(/^\w/, (c) => c.toUpperCase()),
    value,
  }));

  return (
    <>
      <section className="a-section">
        {head}
        {store.days.length === 0 ? (
          <p className="a-card a-empty">{t.storeEmpty}</p>
        ) : (
          <>
            <div className="a-charts">
              <DailyChart
                title={t.impressions}
                summary={t.inPeriod(add(impressions), store.days.length)}
                points={impressions}
                description={describe(t.impressions, impressions)}
              />
              <DailyChart
                title={t.pageViews}
                summary={t.inPeriod(add(pageViews), store.days.length)}
                points={pageViews}
                description={describe(t.pageViews, pageViews)}
              />
            </div>
            <details className="a-details">
              <summary>{t.showTable}</summary>
              <div className="a-card">
                <div className="a-table-wrap">
                  <table className="a-table">
                    <thead>
                      <tr>
                        <th scope="col">{t.tableDay}</th>
                        <th scope="col" className="is-num" title={t.impressionsHint}>
                          {t.impressions}
                        </th>
                        <th scope="col" className="is-num" title={t.pageViewsHint}>
                          {t.pageViews}
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {[...store.days].reverse().map((day) => (
                        <tr key={day.day}>
                          <td>{formatDay(day.day, "long")}</td>
                          <td className="is-num">{day.impressions}</td>
                          <td className="is-num">{day.pageViews}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </details>
          </>
        )}
        {(first && last) || store.stopped ? (
          <p className="a-count a-footnote">
            {[first && last ? t.covers(formatDay(first.day), formatDay(last.day)) : "", store.stopped ? t.analyticsStopped : ""]
              .filter(Boolean)
              .join(" ")}
          </p>
        ) : null}
      </section>

      <section className="a-section">
        <SectionHead title={t.sourcesHeading} caption={t.sourcesCaption} />
        <div className="a-card">
          {sourceTotal === 0 ? (
            <p className="a-empty">{t.sourcesEmpty}</p>
          ) : (
            <>
              <p className="a-count">{t.sourcesOf(sourceTotal)}</p>
              <Breakdown rows={sourceRows} of={sourceTotal} unit={t.dailyDownloads.toLowerCase()} />
            </>
          )}
        </div>
      </section>
    </>
  );
}

// ---------------------------------------------------------------------------
// Countries, crashes, reviews
// ---------------------------------------------------------------------------

const SHOWN_COUNTRIES = 8;

function Countries({ countries }: { countries: Record<string, number> }) {
  const sorted = Object.entries(countries)
    .filter(([, n]) => n > 0)
    .sort(([, a], [, b]) => b - a);
  const all = sorted.reduce((n, [, v]) => n + v, 0);
  const shown = sorted.slice(0, SHOWN_COUNTRIES);
  const rest = sorted.slice(SHOWN_COUNTRIES);
  const rows: BreakdownRow[] = shown.map(([code, value]) => ({ key: code, label: countryName(code), value }));
  if (rest.length > 0) {
    rows.push({ key: "rest", label: t.countriesRest(rest.length), value: rest.reduce((n, [, v]) => n + v, 0) });
  }

  return (
    <section className="a-section">
      <SectionHead title={t.countriesHeading} caption={t.countriesCaption} />
      <div className="a-card">
        {all === 0 ? (
          <p className="a-empty">{t.countriesEmpty}</p>
        ) : (
          <>
            <p className="a-count">{t.countriesOf(all)}</p>
            <Breakdown rows={rows} of={all} unit={t.dailyDownloads.toLowerCase()} />
          </>
        )}
      </div>
    </section>
  );
}

function Crashes({ crashes, delivered }: { crashes: Record<string, number>; delivered: boolean }) {
  const rows = Object.entries(crashes)
    .filter(([, n]) => n > 0)
    .sort(([, a], [, b]) => b - a);
  return (
    <section className="a-section">
      <SectionHead title={t.crashesHeading} caption={t.crashesCaption} />
      {rows.length === 0 ? (
        <p className="a-card a-empty">{delivered ? t.crashesNone : t.crashesWaiting}</p>
      ) : (
        <div className="a-card">
          <div className="a-table-wrap">
            <table className="a-table">
              <thead>
                <tr>
                  <th scope="col">{t.version}</th>
                  <th scope="col" className="is-num">
                    {t.crashes}
                  </th>
                </tr>
              </thead>
              <tbody>
                {rows.map(([version, n]) => (
                  <tr key={version}>
                    <td>{version}</td>
                    <td className="is-num">{formatCount(n)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </section>
  );
}

function Ratings({
  reviews,
  ratingProblem,
  timeZone,
}: {
  reviews: Result<ReviewList> | null;
  ratingProblem: string | null;
  timeZone: string;
}) {
  return (
    <section className="a-section">
      <SectionHead title={t.reviewsHeading} caption={t.reviewsCaption} />
      {!reviews ? (
        <p className="a-card a-empty">{t.reviewsNeedKey}</p>
      ) : "problem" in reviews ? (
        <p className="a-card a-empty">{reviews.problem}</p>
      ) : reviews.data.newest.length === 0 ? (
        <p className="a-card a-empty">{t.reviewsEmpty}</p>
      ) : (
        <div className="a-card">
          <p className="a-count">{t.reviewsCount(reviews.data.newest.length, reviews.data.total)}</p>
          <Reviews reviews={reviews.data.newest} timeZone={timeZone} />
        </div>
      )}
      {ratingProblem && <p className="a-count a-footnote">{ratingProblem}</p>}
    </section>
  );
}
