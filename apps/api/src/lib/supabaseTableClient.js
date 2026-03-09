export class SupabaseTableClient {
  constructor({ supabaseUrl, supabaseAnonKey, schema = "vital" }) {
    this.baseUrl = `${supabaseUrl.replace(/\/$/, "")}/rest/v1`;
    this.anonKey = supabaseAnonKey;
    this.schema = schema;
  }

  headers(accessToken, extra = {}) {
    return {
      apikey: this.anonKey,
      authorization: `Bearer ${accessToken}`,
      "accept-profile": this.schema,
      "content-profile": this.schema,
      ...extra
    };
  }

  async getUserProfile(accessToken) {
    const url = `${this.baseUrl}/user_profiles?select=user_id,profile_context,display_name,timezone,competition_mode&limit=1`;
    const res = await fetch(url, {
      method: "GET",
      headers: this.headers(accessToken)
    });
    const payload = await res.json().catch(() => []);
    if (!res.ok) {
      const err = new Error(payload?.message || payload?.error || "Failed to fetch profile");
      err.status = res.status;
      err.details = payload;
      throw err;
    }
    return Array.isArray(payload) ? payload[0] || null : null;
  }

  async upsertUserProfile(accessToken, row) {
    const url = `${this.baseUrl}/user_profiles?on_conflict=user_id`;
    const res = await fetch(url, {
      method: "POST",
      headers: this.headers(accessToken, {
        "content-type": "application/json",
        prefer: "resolution=merge-duplicates,return=representation"
      }),
      body: JSON.stringify(row)
    });
    const payload = await res.json().catch(() => []);
    if (!res.ok) {
      const err = new Error(payload?.message || payload?.error || "Failed to upsert profile");
      err.status = res.status;
      err.details = payload;
      throw err;
    }
    return Array.isArray(payload) ? payload[0] || null : null;
  }
}
