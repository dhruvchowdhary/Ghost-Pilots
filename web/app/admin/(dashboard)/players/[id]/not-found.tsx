import Link from "next/link";
import { AdminStrings } from "../../../strings";

/// An id the game has nothing under: a link kept from before the database
/// was cleared, usually, or one typed by hand.
export default function PlayerNotFound() {
  return (
    <>
      <Link className="a-back" href="/admin/players">← {AdminStrings.player.back}</Link>
      <p className="a-card a-empty">{AdminStrings.player.notFound}</p>
    </>
  );
}
