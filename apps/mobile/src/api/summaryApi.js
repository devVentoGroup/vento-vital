const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API resumen");
  }
  return payload;
}

export async function getWeeklySummary(jwt, weekStart = null) {
  const params = new URLSearchParams();
  if (weekStart) params.set("week_start", weekStart);
  const query = params.toString();
  const url = `${API_BASE_URL}/api/summary/weekly${query ? `?${query}` : ""}`;
  const res = await fetch(url, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}

