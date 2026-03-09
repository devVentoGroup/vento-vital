const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API safety");
  }
  return payload;
}

export async function submitSafetyIntake(jwt, payload) {
  const res = await fetch(`${API_BASE_URL}/api/safety/intake`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      payload: payload || {}
    })
  });
  const body = await parseApiResponse(res);
  return body.data || null;
}

export async function getSafetyStatus(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/safety/status`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const body = await parseApiResponse(res);
  const data = body.data || [];
  return Array.isArray(data) ? data[0] || null : data;
}
