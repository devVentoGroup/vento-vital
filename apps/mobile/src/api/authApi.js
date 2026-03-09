const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

function requireSupabaseConfig() {
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    throw new Error("Faltan EXPO_PUBLIC_SUPABASE_URL o EXPO_PUBLIC_SUPABASE_ANON_KEY");
  }
}

export async function loginWithPassword(email, password) {
  requireSupabaseConfig();

  const res = await fetch(`${SUPABASE_URL.replace(/\/$/, "")}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      apikey: SUPABASE_ANON_KEY
    },
    body: JSON.stringify({
      email,
      password
    })
  });

  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error_description || payload.msg || payload.error || "No se pudo iniciar sesión");
  }

  if (!payload.access_token) {
    throw new Error("Supabase no devolvió access_token");
  }

  return {
    accessToken: payload.access_token,
    refreshToken: payload.refresh_token || null,
    expiresIn: payload.expires_in || null,
    user: payload.user || null
  };
}

export async function refreshWithToken(refreshToken) {
  requireSupabaseConfig();
  if (!refreshToken) {
    throw new Error("refresh_token is required");
  }

  const res = await fetch(`${SUPABASE_URL.replace(/\/$/, "")}/auth/v1/token?grant_type=refresh_token`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      apikey: SUPABASE_ANON_KEY
    },
    body: JSON.stringify({
      refresh_token: refreshToken
    })
  });

  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error_description || payload.msg || payload.error || "No se pudo refrescar sesión");
  }

  if (!payload.access_token) {
    throw new Error("Supabase no devolvió access_token en refresh");
  }

  return {
    accessToken: payload.access_token,
    refreshToken: payload.refresh_token || refreshToken,
    expiresIn: payload.expires_in || null,
    user: payload.user || null
  };
}
