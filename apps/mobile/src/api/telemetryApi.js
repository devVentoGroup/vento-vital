const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API telemetry");
  }
  return payload;
}

export async function trackEvent(jwt, eventName, payload = {}, source = "app", eventVersion = "v1") {
  const res = await fetch(`${API_BASE_URL}/api/telemetry/track`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      event_name: eventName,
      payload,
      source,
      occurred_at: new Date().toISOString(),
      event_version: eventVersion
    })
  });

  const body = await parseApiResponse(res);
  return body.data || null;
}
