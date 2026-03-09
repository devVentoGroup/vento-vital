const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error de perfil");
  }
  return payload;
}

export async function getProfile(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/profile`, {
    method: "GET",
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}

export async function saveProfile(jwt, profile) {
  const res = await fetch(`${API_BASE_URL}/api/profile`, {
    method: "PUT",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify(profile || {})
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}
