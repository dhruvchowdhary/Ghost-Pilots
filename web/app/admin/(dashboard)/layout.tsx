import { AppSwitcher } from "../components/AppSwitcher";
import { Nav } from "../components/Nav";
import { signOut } from "../lib/actions";
import { requireAdmin } from "../lib/session";
import { AdminStrings } from "../strings";

/// The sidebar every dashboard page shares: which dashboard this is (and the
/// switch to FitPals' and Whensday's), the tabs, and the way out. On a phone
/// it folds into a bar across the top.
///
/// The session is checked here so a signed-out visit goes straight to the
/// login page, but this isn't what keeps the data private - a layout isn't
/// re-run on every navigation. Each read checks for itself (`read` in firebase.ts).
export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  await requireAdmin();

  return (
    <div className="a-shell">
      <aside className="a-sidebar">
        <AppSwitcher />
        <Nav />
        <form action={signOut} className="a-sidebar-foot">
          <button className="a-link-button" type="submit">
            {AdminStrings.signOut}
          </button>
        </form>
      </aside>
      <main>{children}</main>
    </div>
  );
}
