import Link from "next/link";
import { filterHref, RANGES, type Filters as FilterState } from "../lib/params";
import { AdminStrings } from "../strings";

/// The one filter row: the period. Plain links, so it works before any script
/// has loaded and every view has a URL.
export function Filters({ path, filters }: { path: string; filters: FilterState }) {
  return (
    <div className="a-filters">
      <nav className="a-segmented" aria-label={AdminStrings.filters.range}>
        {RANGES.map((range) => (
          <Link
            key={range.key}
            href={filterHref(path, range.key)}
            aria-current={range.key === filters.range.key ? "true" : undefined}
            scroll={false}
          >
            {AdminStrings.filters.ranges[range.key]}
          </Link>
        ))}
      </nav>
    </div>
  );
}
