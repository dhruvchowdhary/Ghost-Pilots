import { Breakdown } from "../components/Breakdown";
import { KpiTile, Problem, SectionHead } from "../components/bits";
import { attempt, getGames, getPlayers, isLive, isPlaying, type Game, type Player } from "../lib/data";
import { formatCount, formatPercent } from "../lib/format";
import { requireAdmin } from "../lib/session";
import { BALANCES, SHOP } from "../labels";
import { AdminStrings } from "../strings";

/// The front page: how many players there are, who's online, how much
/// Polynite is out there and what it's been spent on.
///
/// Where the other two dashboards draw a line a day, this one can't: the game
/// saves no dates, so everything here is a total as of now, and the page says
/// so. Apple's downloads by day are on the App Store tab.
export default async function OverviewPage() {
  await requireAdmin();
  const t = AdminStrings.overview;
  const result = await attempt(Promise.all([getPlayers(), getGames()]));

  return (
    <>
      <div className="a-page-head">
        <div>
          <h1>{t.heading}</h1>
          <p>{t.caption}</p>
        </div>
      </div>

      {"problem" in result ? <Problem message={result.problem} /> : <Body players={result.data[0]} games={result.data[1]} />}
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

function Body({ players, games }: { players: Player[]; games: Game[] }) {
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
