"use client";

import { useEffect, useRef } from "react";
import { CURRENT, DASHBOARDS } from "../dashboards";
import { AdminStrings } from "../strings";

/// The top of the sidebar: which app's dashboard this is, and the way to the
/// other one.
///
/// A `<details>` so it opens and closes with no script at all; the effect only
/// adds what a menu is expected to do on top of that, closing on a click
/// elsewhere or Escape. The other dashboard is a full page load on another
/// domain, never a client-side route.
export function AppSwitcher() {
  const ref = useRef<HTMLDetailsElement>(null);
  const current = DASHBOARDS.find((d) => d.key === CURRENT) ?? DASHBOARDS[0];
  const t = AdminStrings.switcher;

  useEffect(() => {
    function close(event: Event) {
      const details = ref.current;
      if (!details?.open) return;
      if (event instanceof KeyboardEvent) {
        if (event.key !== "Escape") return;
        details.open = false;
        details.querySelector("summary")?.focus();
        return;
      }
      if (!details.contains(event.target as Node)) details.open = false;
    }
    document.addEventListener("pointerdown", close);
    document.addEventListener("keydown", close);
    return () => {
      document.removeEventListener("pointerdown", close);
      document.removeEventListener("keydown", close);
    };
  }, []);

  return (
    <details className="a-switcher" ref={ref}>
      <summary aria-label={`${current.name} ${AdminStrings.badge}. ${t.label}`}>
        <span className="a-app-mark" style={{ background: current.mark }} aria-hidden>
          {current.initial}
        </span>
        <span className="a-switcher-name">
          {current.name} <span className="a-badge">{AdminStrings.badge}</span>
        </span>
        <svg className="a-chevron" viewBox="0 0 16 16" width="14" height="14" aria-hidden>
          <path d="M4.5 6.5 8 10l3.5-3.5" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </summary>
      <div className="a-switcher-menu">
        <p className="a-switcher-label">{t.label}</p>
        <ul>
          {DASHBOARDS.map((d) => {
            const here = d.key === CURRENT;
            return (
              <li key={d.key}>
                <a href={here ? "/admin" : d.url} aria-current={here ? "true" : undefined}>
                  <span className="a-app-mark is-small" style={{ background: d.mark }} aria-hidden>
                    {d.initial}
                  </span>
                  <span className="a-switcher-item">{d.name}</span>
                  {here && (
                    <span className="a-switcher-check">
                      <span aria-hidden>✓</span>
                      <span className="a-sr">{t.current}</span>
                    </span>
                  )}
                </a>
              </li>
            );
          })}
        </ul>
      </div>
    </details>
  );
}
