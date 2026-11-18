/// The filter row's state, kept in the URL so a view can be bookmarked or
/// sent, and so the back button undoes a change of period.
///
/// Period only, and only on the App Store tab: the game saves no dates, so
/// nothing from Firebase can be cut to a period. The players list keeps its
/// own search and sort in the URL the same way (`players/page.tsx`).

export const RANGES = [
  { key: "7d", days: 7 },
  { key: "30d", days: 30 },
  { key: "90d", days: 90 },
] as const;

export type RangeKey = (typeof RANGES)[number]["key"];

export type SearchParams = Record<string, string | string[] | undefined>;

export type Filters = {
  range: (typeof RANGES)[number];
  /// The start of the period, for the reads that take an instant.
  since: Date;
};

export function readFilters(params: SearchParams): Filters {
  const range = RANGES.find((r) => r.key === params.range) ?? RANGES[1];
  return {
    range,
    since: new Date(Date.now() - range.days * 86_400_000),
  };
}

/// The same page with a different period.
export function filterHref(path: string, range: RangeKey): string {
  return range === "30d" ? path : `${path}?range=${range}`;
}
