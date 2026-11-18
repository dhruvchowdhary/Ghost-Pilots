import { redirect } from "next/navigation";
import { CURRENT, DASHBOARDS } from "../dashboards";
import { adminPassword, isSignedIn } from "../lib/session";
import { AdminStrings } from "../strings";
import { LoginForm } from "./LoginForm";

/// The door. Off entirely until `ADMIN_PASSWORD` is set, and it says so
/// rather than taking a password that could never be right.
export default async function LoginPage() {
  if (await isSignedIn()) redirect("/admin");
  const t = AdminStrings.login;
  const app = DASHBOARDS.find((d) => d.key === CURRENT) ?? DASHBOARDS[0];

  return (
    <div className="a-login">
      <section className="a-card">
        <span className="a-brand">
          <span className="a-app-mark" style={{ background: app.mark }} aria-hidden>
            {app.initial}
          </span>
          {AdminStrings.wordmark} <span className="a-badge">{AdminStrings.badge}</span>
        </span>
        <h1>{t.heading}</h1>
        <p>{t.caption}</p>
        {adminPassword() ? <LoginForm /> : <p className="a-error">{t.unconfigured}</p>}
      </section>
    </div>
  );
}
