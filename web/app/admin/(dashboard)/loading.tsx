import { AdminStrings } from "../strings";

/// While a page's reads are out: grey blocks in the shape of what's coming,
/// the same rule the app follows (README, "Skeletons, not spinners").
export default function Loading() {
  return (
    <div aria-busy="true" aria-label={AdminStrings.loading}>
      <span className="a-skel" style={{ width: 180, height: 28, marginBottom: 24 }} />
      <div className="a-kpis">
        {[0, 1, 2, 3].map((i) => (
          <span key={i} className="a-skel" style={{ height: 112 }} />
        ))}
      </div>
      <div className="a-charts is-four a-section">
        {[0, 1, 2, 3].map((i) => (
          <span key={i} className="a-skel" style={{ height: 190 }} />
        ))}
      </div>
      <span className="a-skel a-section" style={{ height: 320 }} />
    </div>
  );
}
