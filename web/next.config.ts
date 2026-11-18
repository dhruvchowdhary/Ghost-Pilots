import type { NextConfig } from "next";

/// The admin dashboard is kept out of search engines and out of other sites'
/// frames. Both are also said by its pages, but a header reaches the login
/// page's redirect too.
const config: NextConfig = {
  async headers() {
    return [
      {
        source: "/admin/:path*",
        headers: [
          { key: "X-Robots-Tag", value: "noindex, nofollow" },
          { key: "Content-Security-Policy", value: "frame-ancestors 'none'" },
          { key: "Referrer-Policy", value: "same-origin" },
        ],
      },
    ];
  },
};

export default config;
