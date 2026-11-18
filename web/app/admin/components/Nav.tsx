"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { AdminStrings } from "../strings";

/// 16pt line icons, one per tab. Drawn here rather than pulled from a set: four
/// of them don't earn a dependency. Overview, App Store and Players are the
/// other dashboards' Overview, App Store and Users icons.
const ICONS = {
  overview: "M2.5 2.5h4.5v4.5H2.5zM9 2.5h4.5v4.5H9zM2.5 9h4.5v4.5H2.5zM9 9h4.5v4.5H9z",
  appStore: "M3.25 5.5h9.5l-.85 8H4.1zM5.75 7.5V4.75a2.25 2.25 0 0 1 4.5 0V7.5",
  players: "M6 7.5a2.25 2.25 0 1 0 0-4.5 2.25 2.25 0 0 0 0 4.5zM1.75 13.5c.4-2.3 2.1-3.75 4.25-3.75s3.85 1.45 4.25 3.75M10.75 7.25a2 2 0 1 0-.5-3.9M11.5 9.9c1.45.35 2.5 1.6 2.75 3.6",
  games: "M5 4.75h6a3.25 3.25 0 0 1 3.25 3.25v1.75a1.75 1.75 0 0 1-3.1 1.1L10 9.5H6l-1.15 1.35a1.75 1.75 0 0 1-3.1-1.1V8A3.25 3.25 0 0 1 5 4.75zM5.25 6.5v2.5M4 7.75h2.5M10.5 7.25v.01M11.75 8.5v.01",
} as const;

const TABS = [
  { href: "/admin", key: "overview", exact: true },
  { href: "/admin/app-store", key: "appStore", exact: false },
  { href: "/admin/players", key: "players", exact: false },
  { href: "/admin/games", key: "games", exact: false },
] as const;

/// The tabs, down the sidebar. A client component only to know which one
/// you're on: a layout isn't told the path, and it doesn't re-render between
/// its pages.
export function Nav() {
  const path = usePathname();
  return (
    <nav className="a-nav" aria-label={AdminStrings.nav.label}>
      {TABS.map((tab) => {
        const current = tab.exact ? path === tab.href : path.startsWith(tab.href);
        return (
          <Link key={tab.href} href={tab.href} aria-current={current ? "page" : undefined}>
            <svg viewBox="0 0 16 16" width="16" height="16" aria-hidden>
              <path d={ICONS[tab.key]} fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
            {AdminStrings.nav[tab.key]}
          </Link>
        );
      })}
    </nav>
  );
}
