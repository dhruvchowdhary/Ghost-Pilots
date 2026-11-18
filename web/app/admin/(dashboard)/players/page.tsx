import Link from "next/link";
import { Problem } from "../../components/bits";
import { attempt, getPlayers, type Player } from "../../lib/data";
import { formatCount } from "../../lib/format";
import type { SearchParams } from "../../lib/params";
import { requireAdmin } from "../../lib/session";
import { itemName, STARTERS } from "../../labels";
import { AdminStrings } from "../../strings";

/// Everyone the game has saved. Searched, sorted and cut down on the server,
/// unlike the other dashboards' user lists: every install is a player here,
/// so the list can run to tens of thousands, far too many to send to the
/// browser whole. The search box and sort are a plain GET form, so every view
/// has a URL and it all works before any script loads.

const PAGE = 100;
const MAX = 2000;

type Sort = keyof typeof AdminStrings.players.sorts;
type Show = keyof typeof AdminStrings.players.shows;

const SORTS: readonly Sort[] = ["polynite", "items", "name"];
const SHOWS: readonly Show[] = ["all", "named", "buyers"];

function one(value: string | string[] | undefined): string {
  return (Array.isArray(value) ? value[0] : value) ?? "";
}

function readView(params: SearchParams) {
  const sort = SORTS.find((s) => s === one(params.sort)) ?? "polynite";
  const show = SHOWS.find((s) => s === one(params.show)) ?? "all";
  const requested = Number(one(params.more));
  const limit = Number.isFinite(requested) ? Math.min(Math.max(requested, PAGE), MAX) : PAGE;
  return { query: one(params.q).trim().slice(0, 100), sort, show, limit };
}

type View = ReturnType<typeof readView>;

/// The same list with some of the view changed. Defaults stay out of the URL.
function viewHref(view: View, change: Partial<View>): string {
  const next = { ...view, ...change };
  const query = new URLSearchParams();
  if (next.query) query.set("q", next.query);
  if (next.sort !== "polynite") query.set("sort", next.sort);
  if (next.show !== "all") query.set("show", next.show);
  if (next.limit !== PAGE) query.set("more", String(next.limit));
  const text = query.toString();
  return text ? `/admin/players?${text}` : "/admin/players";
}

export default async function PlayersPage({ searchParams }: { searchParams: Promise<SearchParams> }) {
  await requireAdmin();
  const view = readView(await searchParams);
  const t = AdminStrings.players;
  const result = await attempt(getPlayers());

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
        <List players={result.data} view={view} />
      )}
    </>
  );
}

const BY: Record<Sort, (a: Player, b: Player) => number> = {
  polynite: (a, b) => b.polynite - a.polynite || b.bought - a.bought,
  items: (a, b) => b.bought - a.bought || b.polynite - a.polynite,
  // Named players first, A to Z, then the rest by balance.
  name: (a, b) =>
    a.name && b.name
      ? a.name.localeCompare(b.name, "en", { sensitivity: "base" })
      : a.name
        ? -1
        : b.name
          ? 1
          : b.polynite - a.polynite,
};

function List({ players, view }: { players: Player[]; view: View }) {
  const t = AdminStrings.players;
  const needle = view.query.toLowerCase();
  const inShow = (p: Player) => view.show === "all" || (view.show === "named" ? p.name !== null : p.bought > 0);
  const counts: Record<Show, number> = {
    all: players.length,
    named: players.filter((p) => p.name !== null).length,
    buyers: players.filter((p) => p.bought > 0).length,
  };

  const matching = players.filter(
    (p) => inShow(p) && (!needle || p.id.toLowerCase().includes(needle) || (p.name?.toLowerCase().includes(needle) ?? false)),
  );
  const shown = [...matching].sort(BY[view.sort]).slice(0, view.limit);

  return (
    <>
      <form className="a-toolbar" method="get" action="/admin/players">
        <input
          className="a-input"
          type="search"
          name="q"
          placeholder={t.search}
          aria-label={t.search}
          defaultValue={view.query}
        />
        <label className="a-muted a-inline-label">
          {t.sort}
          <select className="a-select" name="sort" defaultValue={view.sort}>
            {SORTS.map((key) => (
              <option key={key} value={key}>
                {t.sorts[key]}
              </option>
            ))}
          </select>
        </label>
        {view.show !== "all" && <input type="hidden" name="show" value={view.show} />}
        <button className="a-button is-quiet" type="submit">
          {t.searchButton}
        </button>
      </form>

      <nav className="a-chips" aria-label={t.show}>
        {SHOWS.map((key) => (
          <Link
            key={key}
            className="a-chip"
            href={viewHref(view, { show: key, limit: PAGE })}
            aria-current={view.show === key ? "true" : undefined}
            scroll={false}
          >
            {t.shows[key]} <span className="a-num">{formatCount(counts[key])}</span>
          </Link>
        ))}
      </nav>

      <section className="a-card">
        <p className="a-count" aria-live="polite">
          {t.count(shown.length, matching.length, players.length)}
        </p>
        {shown.length === 0 ? (
          <p className="a-empty">{t.noMatches}</p>
        ) : (
          <div className="a-table-wrap">
            <table className="a-table">
              <thead>
                <tr>
                  <th scope="col">{t.player}</th>
                  <th scope="col" className="is-num">
                    {t.polynite}
                  </th>
                  <th scope="col">{t.owns}</th>
                  <th scope="col">{t.wearing}</th>
                </tr>
              </thead>
              <tbody>
                {shown.map((player) => (
                  <Row key={player.id} player={player} />
                ))}
              </tbody>
            </table>
          </div>
        )}
        {shown.length < matching.length && view.limit < MAX && (
          <Link className="a-more" href={viewHref(view, { limit: Math.min(view.limit + PAGE * 4, MAX) })} scroll={false}>
            {t.showMore}
          </Link>
        )}
      </section>
    </>
  );
}

function Row({ player }: { player: Player }) {
  const t = AdminStrings.players;
  const extras = [...player.decals, ...player.trails].filter((item) => !STARTERS.has(item));
  const wearing = [player.wearingDecal, player.wearingTrail].filter(
    (item): item is string => item !== null && !STARTERS.has(item),
  );
  return (
    <tr>
      <td>
        <span className="a-person">
          <span className="a-person-name">
            <Link href={`/admin/players/${encodeURIComponent(player.id)}`}>
              {player.name ?? <span className="a-muted">{t.noName}</span>}
            </Link>
            <span className="a-sub" title={player.id}>
              {player.id.slice(0, 8)}
            </span>
          </span>
        </span>
      </td>
      <td className="is-num">{player.polynite.toLocaleString("en-US")}</td>
      <td>
        {extras.length === 0 ? (
          <span className="a-muted">{t.nothingExtra}</span>
        ) : (
          <span className="a-tags">
            {extras.map((item) => (
              <span key={item} className="a-tag">
                {itemName(item)}
              </span>
            ))}
          </span>
        )}
      </td>
      <td>{wearing.length === 0 ? <span className="a-muted">{t.nothingExtra}</span> : wearing.map(itemName).join(", ")}</td>
    </tr>
  );
}
