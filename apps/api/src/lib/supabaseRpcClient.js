export class SupabaseRpcClient {
  constructor({ supabaseUrl, supabaseAnonKey, rpcSchema = "vital" }) {
    this.baseUrl = `${supabaseUrl.replace(/\/$/, "")}/rest/v1/rpc`;
    this.anonKey = supabaseAnonKey;
    this.rpcSchema = rpcSchema;
  }

  async call(fnName, body, accessToken) {
    const res = await fetch(`${this.baseUrl}/${fnName}`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        apikey: this.anonKey,
        authorization: `Bearer ${accessToken}`,
        "accept-profile": this.rpcSchema,
        "content-profile": this.rpcSchema
      },
      body: JSON.stringify(body || {})
    });

    const payload = await res.json().catch(() => ({}));
    if (!res.ok) {
      const rawMessage = payload?.message || payload?.error || "RPC call failed";
      const message = /schema must be one of/i.test(rawMessage)
        ? `Supabase API does not expose schema "${this.rpcSchema}". Add it in Project Settings > API > Exposed schemas.`
        : rawMessage;
      const error = new Error(message);
      error.status = res.status;
      error.details = payload;
      throw error;
    }
    return payload;
  }
}
