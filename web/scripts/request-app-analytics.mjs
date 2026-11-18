#!/usr/bin/env node
// Asks Apple to make App Analytics reports for one app: the one-time step the
// admin dashboard's App Store tab waits on for impressions, page views,
// download sources and crashes. Run it again if the tab says Apple stopped.
// web/README.md, "The App Store tab", has the rest. The same file is in every
// dashboard's repo.
//
//   ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_PATH=~/path/AuthKey_….p8 \
//     node scripts/request-app-analytics.mjs <app id> [--history]
//
// The key has to be an Admin one: Apple lets no other role ask. --history
// also asks for a one-time snapshot of everything Apple still has, which it
// allows once a month. Nothing is asked for if a live request is already there.

import { createPrivateKey, sign } from "node:crypto";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";

const [appId, ...flags] = process.argv.slice(2);
const { ASC_KEY_ID: keyId, ASC_ISSUER_ID: issuerId, ASC_KEY_PATH: keyPath } = process.env;
if (!/^\d+$/.test(appId ?? "") || !keyId || !issuerId || !keyPath) {
  console.error("Usage: ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_PATH=… node scripts/request-app-analytics.mjs <app id> [--history]");
  process.exit(1);
}

const part = (value) => Buffer.from(JSON.stringify(value)).toString("base64url");
const now = Math.floor(Date.now() / 1000);
const unsigned = `${part({ alg: "ES256", kid: keyId, typ: "JWT" })}.${part({ iss: issuerId, iat: now, exp: now + 600, aud: "appstoreconnect-v1" })}`;
const key = createPrivateKey(readFileSync(keyPath.replace(/^~(?=\/)/, homedir())));
const token = `${unsigned}.${sign("sha256", Buffer.from(unsigned), { key, dsaEncoding: "ieee-p1363" }).toString("base64url")}`;

async function call(method, path, body) {
  const response = await fetch(`https://api.appstoreconnect.apple.com${path}`, {
    method,
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: body && JSON.stringify(body),
  });
  const json = await response.json().catch(() => ({}));
  if (!response.ok) {
    console.error(`${method} ${path}: ${response.status} ${json.errors?.[0]?.detail ?? ""}`);
    process.exit(1);
  }
  return json;
}

const existing = (await call("GET", `/v1/apps/${appId}/analyticsReportRequests`)).data;
const live = existing.find((r) => r.attributes.accessType === "ONGOING" && !r.attributes.stoppedDueToInactivity);

const wanted = [...(live ? [] : ["ONGOING"]), ...(flags.includes("--history") ? ["ONE_TIME_SNAPSHOT"] : [])];
if (live) console.log(`App ${appId} already has a live request (${live.id}).`);

for (const accessType of wanted) {
  const made = await call("POST", "/v1/analyticsReportRequests", {
    data: {
      type: "analyticsReportRequests",
      attributes: { accessType },
      relationships: { app: { data: { type: "apps", id: appId } } },
    },
  });
  console.log(`Asked for ${accessType} for app ${appId} (${made.data.id}). The first reports take a day or two.`);
}
