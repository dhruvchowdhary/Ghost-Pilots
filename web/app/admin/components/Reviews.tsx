import type { Review } from "../lib/appstore";
import { formatDate } from "../lib/format";
import { AdminStrings } from "../strings";

/// The newest written reviews, as the store shows them: stars, title, what
/// they wrote, and who and when underneath. The stars are a label as well as a
/// picture, so the number never rests on the drawing.
export function Reviews({ reviews, timeZone }: { reviews: Review[]; timeZone: string }) {
  const t = AdminStrings.appStore;
  return (
    <ul className="a-reviews">
      {reviews.map((review) => (
        <li key={review.id || review.at} className="a-review">
          <div className="a-review-head">
            <span className="a-stars" role="img" aria-label={t.stars(review.rating)}>
              {"★".repeat(review.rating)}
              <span className="a-stars-off">{"★".repeat(5 - review.rating)}</span>
            </span>
            {review.title && <strong>{review.title}</strong>}
          </div>
          {review.body && <p>{review.body}</p>}
          <span className="a-sub">{t.reviewMeta(review.author, review.territory, formatDate(review.at, timeZone))}</span>
        </li>
      ))}
    </ul>
  );
}
