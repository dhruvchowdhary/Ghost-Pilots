import Link from "next/link";
import { notFound } from "next/navigation";
import { Pill, Problem, SectionHead } from "../../../components/bits";
import { attempt, displayName, getGames, getPlayer, isLive, isPlayerId, isPlaying, type Game, type Player } from "../../../lib/data";
import { formatAgo, formatDateTime, formatDuration } from "../../../lib/format";
import { mapName, modeName, scene, SHOP } from "../../../labels";
import { adminTimeZone, requireAdmin } from "../../../lib/session";
import { AdminStrings } from "../../../strings";

/// One player: everything the game keeps about them (a balance, a shop, maybe
/// an online name or a Game Center one, and from versions after 3.4, when and
/// what they play), and any online game that lists their name.
export default async function PlayerPage({ params }: { params: Promise<{ id: string }> }) {
  await requireAdmin();
  const id = decoded((await params).id);
  if (!id || !isPlayerId(id)) notFound();

  const result = await attempt(Promise.all([getPlayer(id), getGames()]));
  if ("problem" in result) {
    return (
      <>
        <Link className="a-back" href="/admin/players">← {AdminStrings.player.back}</Link>
        <Problem message={result.problem} />
      </>
    );
  }
  const [player, games] = result.data;
  if (!player) notFound();

  return <PlayerView player={player} games={games} timeZone={await adminTimeZone()} />;
}

/// The id as the game wrote it. Device ids never need escaping, but a link
/// that came through another tool might arrive escaped twice, or broken.
function decoded(segment: string): string | null {
  try {
    return decodeURIComponent(segment);
  } catch {
    return null;
  }
}

function PlayerView({ player, games, timeZone }: { player: Player; games: Game[]; timeZone: string }) {
  const t = AdminStrings.player;
  const owned = new Set([...player.decals, ...player.trails]);
  const wearing = [player.wearingDecal, player.wearingTrail];
  // Online games know players by name only, so this matches on it.
  const theirs = player.name ? games.filter((g) => isLive(g) && g.seats.some((s) => s.seat === "here" && s.name === player.name)) : [];

  return (
    <>
      <Link className="a-back" href="/admin/players">← {t.back}</Link>

      <section className="a-card">
        <div className="a-profile">
          <div>
            <h1>{displayName(player)?.name ?? AdminStrings.players.noName}</h1>
            <p>{t.caption}</p>
          </div>
        </div>

        <dl className="a-facts">
          <div>
            <dt>{t.polynite}</dt>
            <dd>{player.polynite.toLocaleString("en-US")}</dd>
          </div>
          <div>
            <dt>{t.name}</dt>
            <dd>{player.name ?? <span className="a-muted">{t.noName}</span>}</dd>
          </div>
          <div>
            <dt>{t.gameCenter}</dt>
            <dd>{player.gameCenter ?? <span className="a-muted">{t.gameCenterNone}</span>}</dd>
          </div>
          <div>
            <dt>{t.lastActive}</dt>
            <dd>
              {player.lastSeen ? (
                t.lastActiveValue(formatDateTime(player.lastSeen, timeZone), formatAgo(player.lastSeen, timeZone) ?? "")
              ) : (
                <span className="a-muted">{t.notRecorded}</span>
              )}
            </dd>
          </div>
          <div>
            <dt>{t.time}</dt>
            <dd>
              {Object.keys(player.days).length > 0 ? (
                t.timeValue(formatDuration(player.seconds * 1000), Object.keys(player.days).length)
              ) : (
                <span className="a-muted">{t.notRecorded}</span>
              )}
            </dd>
          </div>
          <div>
            <dt title={t.deviceHint}>{t.device}</dt>
            <dd>
              <code className="a-code">{player.id}</code>
            </dd>
          </div>
        </dl>
      </section>

      <section className="a-section">
        <SectionHead title={t.playHeading} caption={t.playCaption} />
        <PlayTable play={player.play} />
      </section>

      <section className="a-section">
        <SectionHead title={t.shopHeading} caption={t.shopCaption} />
        <div className="a-card">
          {!player.shop && <p className="a-count">{t.noShop}</p>}
          <div className="a-table-wrap">
            <table className="a-table">
              <tbody>
                {SHOP.map((item) => {
                  // Before the shop's first save they have the starters,
                  // and wear them.
                  const has = item.starter || owned.has(item.id);
                  const on = wearing.includes(item.id) || (!player.shop && item.starter);
                  return (
                    <tr key={item.id}>
                      <td>{item.name}</td>
                      <td>
                        {on ? (
                          <Pill label={t.wearingNow} tone="good" />
                        ) : has ? (
                          <Pill label={t.owned} tone="neutral" />
                        ) : (
                          <span className="a-muted">{t.notOwned}</span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      <section className="a-section">
        <SectionHead title={t.gamesHeading} caption={t.gamesCaption} />
        {!player.name ? (
          <p className="a-card a-empty">{t.gamesNoName}</p>
        ) : theirs.length === 0 ? (
          <p className="a-card a-empty">{t.gamesNone}</p>
        ) : (
          <div className="a-card">
            <div className="a-table-wrap">
              <table className="a-table">
                <thead>
                  <tr>
                    <th scope="col">{AdminStrings.games.code}</th>
                    <th scope="col">{AdminStrings.games.status}</th>
                    <th scope="col">{AdminStrings.games.mode}</th>
                    <th scope="col">{AdminStrings.games.map}</th>
                  </tr>
                </thead>
                <tbody>
                  {theirs.map((game) => (
                    <tr key={game.code}>
                      <td>
                        <code className="a-code">{game.code}</code>
                      </td>
                      <td>
                        <Pill
                          label={isPlaying(game) ? AdminStrings.games.statusPlaying : AdminStrings.games.statusLobby}
                          tone={isPlaying(game) ? "good" : "neutral"}
                        />
                      </td>
                      <td>{modeName(game.mode) ?? <span className="a-muted">{AdminStrings.games.unknown}</span>}</td>
                      <td>{mapName(game.map) ?? <span className="a-muted">{AdminStrings.games.unknown}</span>}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </section>
    </>
  );
}

/// Each mode and menu they've been in, games first, longest first.
function PlayTable({ play }: { play: Player["play"] }) {
  const t = AdminStrings.overview;
  const rows = Object.entries(play)
    .map(([id, counts]) => ({ id, ...scene(id), ...counts }))
    .sort((a, b) => Number(b.kind === "play") - Number(a.kind === "play") || b.seconds - a.seconds);
  if (rows.length === 0) return <p className="a-card a-empty">{AdminStrings.player.playEmpty}</p>;
  return (
    <div className="a-card">
      <div className="a-table-wrap">
        <table className="a-table">
          <thead>
            <tr>
              <th scope="col">{t.mode}</th>
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
