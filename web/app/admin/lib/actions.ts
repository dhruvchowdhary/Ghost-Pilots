"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import {
  adminPassword,
  isTimeZone,
  newSessionValue,
  passwordMatches,
  SESSION_COOKIE,
  SESSION_SECONDS,
  TIME_ZONE_COOKIE,
} from "./session";

/// Signing in and out, and nothing else: the dashboard only reads. Anything it
/// changed in the game's database would be changed under players mid-game,
/// with no times saved to say when or why.

export type SignInState = { error?: "wrong" | "unconfigured" };

/// Scoped to the dashboard's own paths, so the cookie never rides along with
/// a visit to the rest of the site.
const cookieOptions = {
  httpOnly: true,
  secure: process.env.NODE_ENV === "production",
  sameSite: "lax" as const,
  path: "/admin",
  maxAge: SESSION_SECONDS,
};

/// The login form. Server actions check the request's origin themselves, so a
/// page elsewhere can't post a guess here on somebody's behalf.
export async function signIn(_previous: SignInState, form: FormData): Promise<SignInState> {
  const password = adminPassword();
  if (!password) return { error: "unconfigured" };

  const given = String(form.get("password") ?? "");
  if (!passwordMatches(given, password)) {
    // A beat before saying no, which turns guessing from a script into a wait.
    await new Promise((resolve) => setTimeout(resolve, 800));
    return { error: "wrong" };
  }

  const store = await cookies();
  store.set(SESSION_COOKIE, newSessionValue(password), cookieOptions);

  const zone = String(form.get("tz") ?? "");
  if (isTimeZone(zone)) store.set(TIME_ZONE_COOKIE, zone, cookieOptions);

  redirect("/admin");
}

export async function signOut(): Promise<void> {
  const store = await cookies();
  store.set(SESSION_COOKIE, "", { ...cookieOptions, maxAge: 0 });
  redirect("/admin/login");
}
