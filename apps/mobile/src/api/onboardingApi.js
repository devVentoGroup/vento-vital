const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API onboarding");
  }
  return payload;
}

export async function completeOnboarding(jwt, payload) {
  const res = await fetch(`${API_BASE_URL}/api/onboarding/complete`, {
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
