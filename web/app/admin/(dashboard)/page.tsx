import { Breakdown } from "../components/Breakdown";
import { DailyChart } from "../components/DailyChart";
import { Filters } from "../components/Filters";
import { KpiTile, Problem, SectionHead } from "../components/bits";
import { attempt, getGames, getPlayers, isLive, isPlaying, type Game, type Player } from "../lib/data";
import { formatCount, formatDay, formatDuration, formatPercent } from "../lib/format";
import { readFilters, type SearchParams } from "../lib/params";
import { requireAdmin } from "../lib/session";
import { BALANCES, scene, SHOP } from "../labels";
import { AdminStrings } from "../strings";

/// The front page: how many players there are, who's online, how much
/// Polynite is out there and what it's been spent on.
///
/// Most of it is a total as of now: until 3.4 the game saved no dates. Versions
/// after it save the days they're opened and how long each mode is played, so
/// "Day by day" and "What people play" fill in as players update, and say so
/// until then. Apple's downloads by day are on the App Store tab.
export default async function OverviewPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  await requireAdmin();
  const filters = readFilters(await searchParams);
  const t = AdminStrings.overview;
  const result = await attempt(Promise.all([getPlayers(), getGames()]));

  return (
    <>
      <div className="a-page-head">
        <div>
          <h1>{t.heading}</h1>
          <p>{t.caption}</p>
        </div>
        <Filters path="/admin" filters={filters} />
      </div>

      {"problem" in result ? (
        <Problem message={result.problem} />
      ) : (
        <Body players={result.data[0]} games={result.data[1]} days={filters.range.days} />
      )}
    </>
  );
}

/// Balances above this aren't added to the total. A few devices hold numbers
/// no amount of play would reach (one has 10^22), and a single one of them
/// turns the sum into noise. The bands and the median still count them.
const TOTAL_CAP = 1_000_000;

function median(values: number[]): number {
  if (values.length === 0) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 1 ? sorted[middle] : Math.round((sorted[middle - 1] + sorted[middle]) / 2);
}

function Body({ players, games, days }: { players: Player[]; games: Game[]; days: number }) {
  const t = AdminStrings.overview;
  const everyone = players.length;
  if (everyone === 0) return <p className="a-card a-empty">{t.empty}</p>;

  const named = players.filter((p) => p.name).length;
  const balances = players.map((p) => Math.max(p.polynite, 0));
  const counted = balances.filter((n) => n <= TOTAL_CAP);
  const held = counted.reduce((a, b) => a + b, 0);
  const buyers = players.filter((p) => p.bought > 0).length;

  const live = games.filter(isLive);
  const playing = live.filter(isPlaying).length;
  const online = new Set(live.flatMap((g) => g.seats.filter((s) => s.seat === "here").map((s) => s.name))).size;

  const decalPrice = SHOP.find((i) => i.kind === "decal" && !i.starter)?.price ?? 0;
  const trailPrice = SHOP.find((i) => i.kind === "trail" && !i.starter)?.price ?? 0;
  const forSale = SHOP.filter((item) => !item.starter);

  return (
    <>
      <div className="a-kpis">
        <KpiTile label={t.players} value={formatCount(everyone)} sub={t.playersSub(named)} hint={t.playersHint} />
        <KpiTile
          label={t.online}
          value={formatCount(online)}
          sub={t.onlineSub(playing, live.length - playing)}
          hint={t.onlineHint}
        />
        <KpiTile label={t.polynite} value={formatCount(held)} sub={t.polyniteSub(median(balances), balances.length - counted.length)} hint={t.polyniteHint} />
        <KpiTile
          label={t.buyers}
          value={formatCount(buyers)}
          sub={t.buyersSub(formatPercent(buyers, everyone))}
          hint={t.buyersHint}
        />
      </div>

      <Daily players={players} days={days} />
      <WhatTheyPlay players={players} />

      <div className="a-columns is-even a-section">
        <section>
          <SectionHead title={t.shopHeading} caption={t.shopCaption(decalPrice, trailPrice)} />
          <div className="a-card">
            <p className="a-count">{t.shopOf(everyone)}</p>
            <Breakdown
              of={everyone}
              unit="players"
              rows={forSale.map((item) => {
                const owners = players.filter((p) => (item.kind === "decal" ? p.decals : p.trails).includes(item.id));
                const wearing = players.filter((p) => (item.kind === "decal" ? p.wearingDecal : p.wearingTrail) === item.id);
                return { key: item.id, label: item.name, hint: t.wearing(wearing.length), value: owners.length };
              })}
            />
          </div>
        </section>

        <section>
          <SectionHead title={t.balanceHeading} caption={t.balanceCaption} />
          <div className="a-card">
            <Breakdown
              of={everyone}
              unit="players"
              rows={BALANCES.map((band) => ({
                key: band.key,
                label: band.label,
                hint: band.hint,
                value: balances.filter((n) => n >= band.min && n <= band.max).length,
              }))}
            />
          </div>
        </section>
      </div>
    </>
  );
}

// ---------------------------------------------------------------------------
// Day by day, from Users/<device>/Days
// ---------------------------------------------------------------------------

/// The `count` UTC days ending today, oldest first. The game files a day
/// under its UTC date, so the chart does too.
function utcDays(count: number): string[] {
  const today = new Date();
  return Array.from({ length: count }, (_, i) => {
    const day = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate() - (count - 1 - i)));
    return day.toISOString().slice(0, 10);
  });
}

function Daily({ players, days }: { players: Player[]; days: number }) {
  const t = AdminStrings.overview;
  const recording = players.some((p) => Object.keys(p.days).length > 0);
  const series = utcDays(days).map((day) => {
    const open = players.filter((p) => day in p.days);
    return {
      day,
      active: open.length,
      minutes: Math.round(open.reduce((n, p) => n + p.days[day], 0) / 60),
    };
  });
  const charts = [
    { key: "active" as const, title: t.dailyActive },
    { key: "minutes" as const, title: t.dailyMinutes },
  ];

  return (
    <section className="a-section">
      <SectionHead title={t.dailyHeading} caption={t.dailyCaption} />
      {!recording ? (
        <p className="a-card a-empty">{t.dailyEmpty}</p>
      ) : (
        <>
          <div className="a-charts">
            {charts.map((chart) => {
              const points = series.map((d) => ({ label: formatDay(d.day), value: d[chart.key] }));
              const peak = series.reduce((best, d) => (d[chart.key] > best[chart.key] ? d : best), series[0]);
              const total = series.reduce((n, d) => n + d[chart.key], 0);
              return (
                <DailyChart
                  key={chart.key}
                  title={chart.title}
                  summary={chart.key === "active" ? t.today(series.at(-1)?.active ?? 0) : t.inPeriod(total, days)}
                  points={points}
                  description={t.describe(chart.title, days, peak[chart.key], formatDay(peak.day))}
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
                      {charts.map((chart) => (
                        <th key={chart.key} scope="col" className="is-num">
                          {chart.title}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {[...series].reverse().map((d) => (
                      <tr key={d.day}>
                        <td>{formatDay(d.day, "long")}</td>
                        <td className="is-num">{d.active}</td>
                        <td className="is-num">{d.minutes}</td>
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
// What people play, from Users/<device>/Play
// ---------------------------------------------------------------------------

type SceneTotal = { id: string; name: string; group: string; plays: number; seconds: number; players: number };

function WhatTheyPlay({ players }: { players: Player[] }) {
  const t = AdminStrings.overview;
  const totals = new Map<string, SceneTotal>();
  for (const player of players) {
    for (const [id, counts] of Object.entries(player.play)) {
      const row = totals.get(id) ?? { id, ...scene(id), plays: 0, seconds: 0, players: 0 };
      row.plays += counts.plays;
      row.seconds += counts.seconds;
      row.players += 1;
      totals.set(id, row);
    }
  }
  const byTime = (a: SceneTotal, b: SceneTotal) => b.seconds - a.seconds || b.plays - a.plays;
  const games = [...totals.values()].filter((r) => scene(r.id).kind === "play").sort(byTime);
  const menus = [...totals.values()].filter((r) => scene(r.id).kind === "menu").sort(byTime);

  return (
    <section className="a-section">
      <SectionHead title={t.playHeading} caption={t.playCaption} />
      {totals.size === 0 ? (
        <p className="a-card a-empty">{t.playEmpty}</p>
      ) : (
        <>
          {games.length > 0 && <SceneTable rows={games} />}
          {menus.length > 0 && (
            <details className="a-details">
              <summary>{t.menusHeading}</summary>
              <SceneTable rows={menus} />
            </details>
          )}
        </>
      )}
    </section>
  );
}

function SceneTable({ rows }: { rows: SceneTotal[] }) {
  const t = AdminStrings.overview;
  return (
    <div className="a-card">
      <div className="a-table-wrap">
        <table className="a-table">
          <thead>
            <tr>
              <th scope="col">{t.mode}</th>
              <th scope="col" className="is-num">
                {t.players}
              </th>
              <th scope="col" className="is-num">
                {t.plays}
              </th>
              <th scope="col" className="is-num">
                {t.time}
              </th>
              <th scope="col" className="is-num">
                {t.perPlay}
              </th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id}>
                <td>
                  {row.name}
                  <span className="a-sub">{row.group}</span>
                </td>
                <td className="is-num">{row.players.toLocaleString("en-US")}</td>
                <td className="is-num">{row.plays.toLocaleString("en-US")}</td>
                <td className="is-num">{formatDuration(row.seconds * 1000)}</td>
                <td className="is-num">{row.plays > 0 ? formatDuration((row.seconds / row.plays) * 1000) : ""}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
