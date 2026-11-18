"use client";

import { useState, type KeyboardEvent, type PointerEvent } from "react";

type Point = { label: string; value: number };

/// The smallest round top for the axis that clears `max`, chosen so the
/// halfway line is a whole number too: 0 / 2 / 4, 0 / 15 / 30, 0 / 50 / 100.
/// The in-between steps keep a peak of 22 from getting an axis to 40.
function niceTop(max: number): number {
  if (max <= 0) return 2;
  const half = max / 2;
  const magnitude = 10 ** Math.floor(Math.log10(half));
  const step =
    [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10]
      .map((m) => m * magnitude)
      .find((s) => s >= half && Number.isInteger(s)) ?? Math.ceil(half);
  return Math.max(2, step * 2);
}

function compact(n: number): string {
  return n >= 1000 ? `${Math.round(n / 100) / 10}K` : String(n);
}

/// One measure, a line a day. The crosshair snaps to the nearest day, so
/// reading a value means pointing at a date rather than landing on a 2px line,
/// and the arrow keys walk it for anyone on a keyboard. The numbers are also in
/// the table under the charts, so none of this is the only way to read them.
export function DailyChart({
  title,
  summary,
  points,
  description,
}: {
  title: string;
  summary: string;
  points: Point[];
  /// What the chart says, for screen readers: the table is the detail.
  description: string;
}) {
  const [active, setActive] = useState<number | null>(null);
  const count = points.length;
  if (count === 0) return null;

  const top = niceTop(Math.max(...points.map((p) => p.value)));
  const x = (i: number) => (count === 1 ? 50 : (i / (count - 1)) * 100);
  const y = (value: number) => 100 - (value / top) * 100;

  const line = points.map((p, i) => `${i === 0 ? "M" : "L"}${x(i) * 10},${y(p.value)}`).join(" ");
  const area = `${line} L${x(count - 1) * 10},100 L${x(0) * 10},100 Z`;
  const ticks = [top, top / 2, 0];
  const last = count - 1;

  function point(event: PointerEvent<HTMLDivElement>) {
    const box = event.currentTarget.getBoundingClientRect();
    const ratio = Math.min(Math.max((event.clientX - box.left) / box.width, 0), 1);
    setActive(Math.round(ratio * last));
  }

  function key(event: KeyboardEvent<HTMLDivElement>) {
    const moves: Record<string, (i: number) => number> = {
      ArrowLeft: (i) => Math.max(0, i - 1),
      ArrowRight: (i) => Math.min(last, i + 1),
      Home: () => 0,
      End: () => last,
    };
    if (event.key === "Escape") return setActive(null);
    const move = moves[event.key];
    if (!move) return;
    event.preventDefault();
    setActive((i) => move(i ?? last));
  }

  const shown = active === null ? null : points[active];

  return (
    <figure className="a-card chart">
      <figcaption className="chart-head">
        <span className="chart-title">{title}</span>
        <span className="chart-summary">{summary}</span>
      </figcaption>
      <div className="chart-body">
        <div className="chart-y" aria-hidden>
          {ticks.map((tick) => (
            <span key={tick} style={{ top: `${y(tick)}%` }}>
              {compact(tick)}
            </span>
          ))}
        </div>
        <div
          className="chart-plot"
          tabIndex={0}
          role="img"
          aria-label={description}
          onPointerMove={point}
          onPointerDown={point}
          onPointerLeave={() => setActive(null)}
          onFocus={() => setActive(last)}
          onBlur={() => setActive(null)}
          onKeyDown={key}
        >
          <svg viewBox="0 0 1000 100" preserveAspectRatio="none" aria-hidden>
            {ticks.map((tick) => (
              <line
                key={tick}
                className={tick === 0 ? "chart-grid is-base" : "chart-grid"}
                x1="0"
                x2="1000"
                y1={y(tick)}
                y2={y(tick)}
                vectorEffect="non-scaling-stroke"
              />
            ))}
            <path className="chart-area" d={area} />
            <path className="chart-line" d={line} vectorEffect="non-scaling-stroke" />
          </svg>

          {/* Dots are drawn over the SVG rather than in it, because the SVG
              stretches to the card and a circle in it would stretch too. */}
          {active === null && (
            <span className="chart-dot" style={{ left: `${x(last)}%`, top: `${y(points[last].value)}%` }} />
          )}
          {shown && active !== null && (
            <>
              <span className="chart-crosshair" style={{ left: `${x(active)}%` }} />
              <span className="chart-dot" style={{ left: `${x(active)}%`, top: `${y(shown.value)}%` }} />
              <span className={x(active) > 55 ? "chart-tip is-left" : "chart-tip"} style={{ left: `${x(active)}%` }}>
                <strong>{shown.value.toLocaleString("en-US")}</strong>
                <span>{shown.label}</span>
              </span>
            </>
          )}
        </div>
        <span aria-hidden />
        <div className="chart-x" aria-hidden>
          <span>{points[0].label}</span>
          <span>{points[last].label}</span>
        </div>
      </div>
    </figure>
  );
}
