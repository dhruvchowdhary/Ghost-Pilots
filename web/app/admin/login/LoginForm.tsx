"use client";

import { useActionState, useEffect, useRef } from "react";
import { signIn, type SignInState } from "../lib/actions";
import { AdminStrings } from "../strings";

/// The password, and the browser's time zone riding along in a hidden field:
/// it's what decides where the dashboard's days start, and only the browser
/// knows it.
export function LoginForm() {
  const [state, action, pending] = useActionState<SignInState, FormData>(signIn, {});
  const zone = useRef<HTMLInputElement>(null);
  const t = AdminStrings.login;

  useEffect(() => {
    if (zone.current) zone.current.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
  }, []);

  return (
    <form action={action} className="a-form">
      <label>
        {t.password}
        <input
          className="a-input"
          type="password"
          name="password"
          autoComplete="current-password"
          required
          autoFocus
        />
      </label>
      <input type="hidden" name="tz" ref={zone} />
      {state.error && (
        <p className="a-error" role="alert">
          {state.error === "wrong" ? t.wrong : t.unconfigured}
        </p>
      )}
      <button className="a-button" type="submit" disabled={pending}>
        {pending ? t.submitting : t.submit}
      </button>
    </form>
  );
}
