import { Breakdown } from "../../components/Breakdown";
import { KpiTile, Pill, Problem, SectionHead } from "../../components/bits";
import { attempt, getGames, isLive, isPlaying, type Game } from "../../lib/data";
import { formatCount } from "../../lib/format";
import { requireAdmin } from "../../lib/session";
import { MAPS, MODES, mapName, modeName } from "../../labels";
import { AdminStrings } from "../../strings";

/// The online side: what's being played and waiting right now, which modes
/// and maps people pick, and what's been left behind.
///
/// "Right now" is as the database has it. The game writes no times, so a
/// player whose app died mid-lobby looks the same as one still in it, and
/// the page says so rather than guessing.
export default async function GamesPage() {
  await requireAdmin();
  const t = AdminStrings.games;
  const result = await attempt(getGames());

  return (
    <>
      <div className="a-page-head">
        <div>
          <h1>{t.heading}</h1>
          <p>{t.caption}</p>
        </div>
      </div>

      {"problem" in result ? (
        <Problem message={result.problem} />
      ) : result.data.length === 0 ? (
        <p className="a-card a-empty">{t.empty}</p>
      ) : (
        <Body games={result.data} />
      )}
    </>
  );
}

/// Being played before waiting, then fuller before emptier. Codes are numbers
/// the host's phone picked at random, so they only settle ties.
function liveOrder(a: Game, b: Game): number {
  return Number(isPlaying(b)) - Number(isPlaying(a)) || here(b) - here(a) || a.code.localeCompare(b.code);
}

function here(game: Game): number {
  return game.seats.filter((s) => s.seat === "here").length;
}

/// Counts by a field, with the game's own values first in the game's order,
/// then anything else it once wrote, then games without one.
function tally(games: Game[], pick: (g: Game) => string | null, known: Record<string, string>, name: (v: string) => string | null) {
  const counts = new Map<string, number>();
  for (const game of games) {
    const value = pick(game) ?? "";
    counts.set(value, (counts.get(value) ?? 0) + 1);
  }
  const order = [...Object.keys(known), ...[...counts.keys()].filter((k) => k && !(k in known)).sort(), ""];
  return order
    .filter((key) => counts.get(key))
    .map((key) => ({ key: key || "none", label: (key && name(key)) || AdminStrings.games.unknown, value: counts.get(key) ?? 0 }));
}

const SHOWN_LEFT = 50;

function Body({ games }: { games: Game[] }) {
  const t = AdminStrings.games;
  const live = games.filter(isLive).sort(liveOrder);
  const left = games.filter((g) => !isLive(g)).sort((a, b) => a.code.localeCompare(b.code));
  const playing = live.filter(isPlaying).length;
  const queued = live.filter((g) => g.queued).length;
  const seated = new Set(live.flatMap((g) => g.seats.filter((s) => s.seat === "here").map((s) => s.name))).size;

  return (
    <>
      <div className="a-kpis">
        <KpiTile label={t.playing} value={formatCount(playing)} />
        <KpiTile label={t.lobbies} value={formatCount(live.length - playing)} sub={queued > 0 ? t.queue(queued) : undefined} />
        <KpiTile label={t.players} value={formatCount(seated)} />
        <KpiTile label={t.leftBehind} value={formatCount(left.length)} hint={t.leftBehindHint} />
      </div>

      <section className="a-section">
        <SectionHead title={t.liveHeading} caption={t.liveCaption} />
        {live.length === 0 ? <p className="a-card a-empty">{t.liveEmpty}</p> : <GamesTable games={live} />}
      </section>

      <div className="a-columns is-even a-section">
        <section>
          <SectionHead title={t.modesHeading} caption={t.modesCaption} />
          <div className="a-card">
            <p className="a-count">{t.ofGames(games.length)}</p>
            <Breakdown of={games.length} unit="games" rows={tally(games, (g) => g.mode, MODES, modeName)} />
          </div>
        </section>
        <section>
          <SectionHead title={t.mapsHeading} caption={t.mapsCaption} />
          <div className="a-card">
            <p className="a-count">{t.ofGames(games.length)}</p>
            <Breakdown of={games.length} unit="games" rows={tally(games, (g) => g.map, MAPS, mapName)} />
          </div>
        </section>
      </div>

      <section className="a-section">
        <SectionHead title={t.leftHeading} caption={t.leftCaption} />
        {left.length === 0 ? (
          <p className="a-card a-empty">{t.leftNone}</p>
        ) : left.length <= SHOWN_LEFT ? (
          <GamesTable games={left} />
        ) : (
          <details className="a-details">
            <summary>{t.showLeft(left.length)}</summary>
            <GamesTable games={left} />
          </details>
        )}
      </section>
    </>
  );
}

function GamesTable({ games }: { games: Game[] }) {
  const t = AdminStrings.games;
  return (
    <div className="a-card">
      <div className="a-table-wrap">
        <table className="a-table">
          <thead>
            <tr>
              <th scope="col">{t.code}</th>
              <th scope="col">{t.status}</th>
              <th scope="col">{t.mode}</th>
              <th scope="col">{t.map}</th>
              <th scope="col">{t.host}</th>
              <th scope="col">{t.who}</th>
            </tr>
          </thead>
          <tbody>
            {games.map((game) => {
              const inIt = game.seats.filter((s) => s.seat === "here");
              const gone = game.seats.filter((s) => s.seat === "left").length;
              const kicked = game.seats.filter((s) => s.seat === "kicked").length;
              return (
                <tr key={game.code}>
                  <td>
                    <code className="a-code">{game.code}</code>
                    {game.public && (
                      <>
                        {" "}
                        <span className="a-tag">{t.publicTag}</span>
                      </>
                    )}
                  </td>
                  <td>
                    {!isLive(game) ? (
                      <span className="a-muted">{t.statusLeft}</span>
                    ) : isPlaying(game) ? (
                      <Pill label={t.statusPlaying} tone="good" />
                    ) : (
                      <Pill label={t.statusLobby} tone="neutral" />
                    )}
                  </td>
                  <td>{modeName(game.mode) ?? <span className="a-muted">{t.unknown}</span>}</td>
                  <td>{mapName(game.map) ?? <span className="a-muted">{t.unknown}</span>}</td>
                  <td>{game.host ?? <span className="a-muted">{t.unknown}</span>}</td>
                  <td>
                    {inIt.length > 0 && (
                      <span className="a-tags">
                        {inIt.map((s) => (
                          <span key={s.name} className="a-tag">
                            {s.name}
                          </span>
                        ))}
                      </span>
                    )}
                    {(gone > 0 || kicked > 0) && (
                      <span className="a-sub">{[gone > 0 ? t.left(gone) : "", kicked > 0 ? t.kicked(kicked) : ""].filter(Boolean).join(" · ")}</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
