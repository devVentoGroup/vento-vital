const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API sports profile");
  }
  return payload;
}

export async function getSportsProfile(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/sports-profile/me`, {
    method: "GET",
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  const data = payload.data || [];
  if (Array.isArray(data)) return data[0] || null;
  return data;
}

export async function updateSportsProfile(jwt, payload) {
  const res = await fetch(`${API_BASE_URL}/api/sports-profile/me`, {
    method: "PUT",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      payload: payload || {}
    })
  });
  const parsed = await parseApiResponse(res);
  const data = parsed.data || [];
  if (Array.isArray(data)) return data[0] || null;
  return data;
}
