import { formatCount, formatPercent } from "../lib/format";
import { Bar } from "./bits";

export type BreakdownRow = { key: string; label: string; value: number; hint?: string };

/// Rows of label, bar and count, each bar a share of `of`: players owning an
/// item, games by mode, downloads by source. The same row FitPals' funnel
/// draws, without the drop-off between rungs, because none of these is a step
/// on the way to the next. The same file as Whensday's apart from this comment.
///
/// One colour throughout. The rows are already labelled, so a hue per row
/// would only say the same thing twice.
export function Breakdown({ rows, of, unit }: { rows: BreakdownRow[]; of: number; unit?: string }) {
  return (
    <ul className="a-breakdown">
      {rows.map((row) => (
        <li key={row.key} className="a-funnel-row" title={`${row.value} of ${of}${unit ? ` ${unit}` : ""} (${formatPercent(row.value, of)})`}>
          <span className="a-funnel-label">
            {row.label}
            {row.hint && <span className="a-sub">{row.hint}</span>}
          </span>
          <Bar value={row.value} max={of} />
          <span className="a-funnel-value">
            {formatCount(row.value)}
            <span className="a-muted">{formatPercent(row.value, of)}</span>
          </span>
        </li>
      ))}
    </ul>
  );
}
