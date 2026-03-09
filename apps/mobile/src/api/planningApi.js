const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API planning");
  }
  return payload;
}

export async function getWeeklyPlan(jwt, weekStart = null, objective = null) {
  const params = new URLSearchParams();
  if (weekStart) params.set("week_start", weekStart);
  if (objective) params.set("objective", objective);
  const query = params.toString();
  const url = `${API_BASE_URL}/api/planning/weekly${query ? `?${query}` : ""}`;

  const res = await fetch(url, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return Array.isArray(payload.data) ? payload.data : [];
}

export async function getCycleAdjustment(jwt, targetDate = null) {
  const params = new URLSearchParams();
  if (targetDate) params.set("date", targetDate);
  const query = params.toString();
  const url = `${API_BASE_URL}/api/planning/cycle${query ? `?${query}` : ""}`;

  const res = await fetch(url, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return Array.isArray(payload.data) ? payload.data : [];
}
