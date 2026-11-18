import { APP_STORE_URL, Strings } from "./strings";

/// The domain root, so it isn't a 404 for anyone who trims the dashboard's
/// address back to it. The site exists for the dashboard; this only points at
/// the game.
export default function Home() {
  return (
    <main>
      <h1>{Strings.site.name}</h1>
      <p>{Strings.site.description}</p>
      <a className="button" href={APP_STORE_URL}>
        {Strings.home.get}
      </a>
    </main>
  );
}
