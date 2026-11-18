/// Numbers, lengths of time and dates, the way the dashboard writes them.
/// Dates are drawn in the admin's own time zone, which the login form sent.

export function formatCount(n: number): string {
  if (n < 10_000) return n.toLocaleString("en-US");
  if (n < 1_000_000) return `${(n / 1000).toFixed(n < 100_000 ? 1 : 0).replace(/\.0$/, "")}K`;
  return `${(n / 1_000_000).toFixed(1).replace(/\.0$/, "")}M`;
}

export function formatPercent(part: number, whole: number): string {
  if (whole <= 0) return "0%";
  const pct = (part / whole) * 100;
  if (pct > 0 && pct < 1) return "<1%";
  return `${Math.round(pct)}%`;
}

/// "45s", "3m 12s", "1h 04m", "2d 3h".
export function formatDuration(ms: number | null | undefined): string {
  if (!ms || ms < 1000) return ms && ms > 0 ? "<1s" : "0s";
  const seconds = Math.round(ms / 1000);
  if (seconds < 60) return `${seconds}s`;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ${String(seconds % 60).padStart(2, "0")}s`;
  const hours = Math.floor(minutes / 60);
  if (hours < 48) return `${hours}h ${String(minutes % 60).padStart(2, "0")}m`;
  return `${Math.floor(hours / 24)}d ${hours % 24}h`;
}

/// A `yyyy-MM-dd` day from Postgres, which has no time zone of its own.
export function formatDay(day: string, style: "short" | "long" = "short"): string {
  const date = new Date(`${day}T12:00:00Z`);
  return date.toLocaleDateString("en-US", {
    timeZone: "UTC",
    month: "short",
    day: "numeric",
    ...(style === "long" ? { weekday: "short" } : {}),
  });
}

export function formatDate(iso: string | null | undefined, timeZone: string): string {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString("en-US", {
    timeZone,
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

export function formatDateTime(iso: string, timeZone: string): string {
  const date = new Date(iso);
  const now = new Date();
  const sameYear =
    date.toLocaleDateString("en-US", { timeZone, year: "numeric" }) ===
    now.toLocaleDateString("en-US", { timeZone, year: "numeric" });
  return date.toLocaleString("en-US", {
    timeZone,
    weekday: "short",
    month: "short",
    day: "numeric",
    ...(sameYear ? {} : { year: "numeric" }),
    hour: "numeric",
    minute: "2-digit",
  });
}

export function formatTime(iso: string, timeZone: string): string {
  return new Date(iso).toLocaleTimeString("en-US", {
    timeZone,
    hour: "numeric",
    minute: "2-digit",
    second: "2-digit",
  });
}

/// "just now", "12m ago", "3h ago", "5d ago", then the date.
export function formatAgo(iso: string | null | undefined, timeZone: string): string | null {
  if (!iso) return null;
  const seconds = (Date.now() - new Date(iso).getTime()) / 1000;
  if (seconds < 60) return "just now";
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
  if (seconds < 86_400) return `${Math.floor(seconds / 3600)}h ago`;
  if (seconds < 86_400 * 30) return `${Math.floor(seconds / 86_400)}d ago`;
  return formatDate(iso, timeZone);
}

/// "$12.34", "CA$3.50", "€2.00". Proceeds arrive in each storefront's own
/// currency and are shown that way, never converted at a made-up rate.
export function formatMoney(amount: number, currency: string): string {
  try {
    return amount.toLocaleString("en-US", { style: "currency", currency });
  } catch {
    return `${amount.toFixed(2)} ${currency}`;
  }
}

const REGIONS = new Intl.DisplayNames(["en"], { type: "region" });

/// "United States" for "US". Apple's reports give two-letter codes.
export function countryName(code: string): string {
  try {
    return REGIONS.of(code.toUpperCase()) ?? code;
  } catch {
    return code;
  }
}
