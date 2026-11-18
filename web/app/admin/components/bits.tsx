import { AdminStrings } from "../strings";

/// The small pieces every page is built from. No hooks and no server-only
/// imports, so client components can use them too. The same as the other two
/// dashboards' apart from what they show about a person: players here have no
/// face or account status, so there's no Avatar or StatusPill, and `Pill`
/// takes its words from the caller.

export type Tone = "good" | "warning" | "critical" | "neutral";

/// A state in words, with a dot beside it. The dot only repeats the word, so
/// nothing rests on the colour alone.
export function Pill({ label, tone, hint }: { label: string; tone: Tone; hint?: string }) {
  return (
    <span className="a-pill" title={hint}>
      <span className={`a-dot is-${tone}`} aria-hidden />
      {label}
    </span>
  );
}

/// A bar grown from the left, as a share of the biggest one shown with it.
export function Bar({ value, max, title }: { value: number; max: number; title?: string }) {
  const width = max > 0 ? Math.max((value / max) * 100, value > 0 ? 1 : 0) : 0;
  return (
    <span className="a-track" title={title}>
      <span className="a-bar" style={{ width: `${width}%` }} />
    </span>
  );
}

/// A headline number, what it means, and how it moved. The direction gets an
/// arrow as well as a colour, so it never rests on the colour alone.
export function KpiTile({
  label,
  value,
  sub,
  delta,
  hint,
}: {
  label: string;
  value: string;
  sub?: string;
  delta?: { text: string; direction: "up" | "down" | "flat" };
  /// What exactly is counted, on hover.
  hint?: string;
}) {
  return (
    <section className="a-card a-kpi" title={hint}>
      <span className="a-kpi-label">{label}</span>
      <span className="a-kpi-value">{value}</span>
      {sub && <span className="a-kpi-sub">{sub}</span>}
      {delta && (
        <span className={`a-delta is-${delta.direction}`}>
          {delta.direction === "up" ? "▲ " : delta.direction === "down" ? "▼ " : ""}
          {delta.text}
        </span>
      )}
    </section>
  );
}

export function Problem({ message }: { message: string }) {
  return (
    <section className="a-card a-problem" role="alert">
      <h2>{AdminStrings.problem.heading}</h2>
      <p>{message}</p>
    </section>
  );
}

export function SectionHead({ title, caption }: { title: string; caption?: string }) {
  return (
    <div className="a-section-head">
      <h2>{title}</h2>
      {caption && <p>{caption}</p>}
    </div>
  );
}
