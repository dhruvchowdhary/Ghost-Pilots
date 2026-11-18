import type { Metadata } from "next";
import { Strings } from "./strings";
import "./globals.css";

export const metadata: Metadata = {
  title: Strings.site.name,
  description: Strings.site.description,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
