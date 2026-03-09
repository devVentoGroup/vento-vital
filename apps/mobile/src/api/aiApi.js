const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API IA");
  }
  return payload;
}

export async function previewAiWeeklyPlan(jwt, targetDate = null) {
  const query = targetDate ? `?date=${encodeURIComponent(targetDate)}` : "";
  const res = await fetch(`${API_BASE_URL}/api/ai/plan/preview${query}`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}

export async function applyAiWeeklyPlan(jwt, proposalPayload) {
  const res = await fetch(`${API_BASE_URL}/api/ai/plan/apply`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({
      proposal_payload: proposalPayload || {}
    })
  });
  const payload = await parseApiResponse(res);
  return payload.data || null;
}

export async function adjustAiHoy(jwt, targetDate = null) {
  const query = targetDate ? `?date=${encodeURIComponent(targetDate)}` : "";
  const res = await fetch(`${API_BASE_URL}/api/ai/hoy/adjust${query}`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return Array.isArray(payload.data) ? payload.data : [];
}

