const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API nutricion");
  }
  return payload;
}

export async function getNutritionProfile(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/nutrition/profile`, {
    method: "GET",
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}

export async function updateNutritionProfile(jwt, profilePayload) {
  const res = await fetch(`${API_BASE_URL}/api/nutrition/profile`, {
    method: "PUT",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      payload: profilePayload || {}
    })
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}

export async function upsertNutritionDailyLog(jwt, inputDate, payload) {
  const res = await fetch(`${API_BASE_URL}/api/nutrition/log`, {
    method: "PUT",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      input_date: inputDate || null,
      payload: payload || {}
    })
  });
  const parsed = await parseApiResponse(res);
  return parsed.data || null;
}

export async function listNutritionDailyLogs(jwt, from = null, to = null) {
  const params = new URLSearchParams();
  if (from) params.set("from", from);
  if (to) params.set("to", to);
  const query = params.toString();
  const url = `${API_BASE_URL}/api/nutrition/logs${query ? `?${query}` : ""}`;

  const res = await fetch(url, {
    method: "GET",
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return Array.isArray(payload.data) ? payload.data : [];
}

