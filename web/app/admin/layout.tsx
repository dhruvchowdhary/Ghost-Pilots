import type { Metadata } from "next";
import { AdminStrings } from "./strings";
import "./admin.css";

export const metadata: Metadata = {
  title: AdminStrings.title,
  robots: { index: false, follow: false },
};

/// Rendered on every request. Each page here reads the session cookie anyway,
/// and nothing behind a password should ever be baked into static HTML.
export const dynamic = "force-dynamic";

/// The admin dashboard's shell: its own styles, scoped so the public pages
/// never see them. The login page and the dashboard both sit inside it; only
/// the dashboard's pages get the header (see `(dashboard)/layout.tsx`).
export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return <div className="admin">{children}</div>;
}
