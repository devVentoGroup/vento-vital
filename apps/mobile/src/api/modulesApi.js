const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API modules");
  }
  return payload;
}

export async function getModulesCatalog(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/modules/catalog`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || [];
}

export async function getMyModulePreferences(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/modules/me`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || [];
}

export async function updateMyModulePreferences(jwt, modules) {
  const res = await fetch(`${API_BASE_URL}/api/modules/me`, {
    method: "PUT",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      modules: modules || []
    })
  });
  const payload = await parseApiResponse(res);
  return payload.data || [];
}
