const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API notifications");
  }
  return payload;
}

function authHeaders(jwt) {
  return {
    authorization: `Bearer ${jwt}`,
    "content-type": "application/json"
  };
}

export async function listNotificationPlans(jwt) {
  const res = await fetch(`${API_BASE_URL}/api/notifications/plans`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || [];
}

export async function upsertNotificationPlan(jwt, payload) {
  const res = await fetch(`${API_BASE_URL}/api/notifications/plans/upsert`, {
    method: "POST",
    headers: authHeaders(jwt),
    body: JSON.stringify(payload)
  });
  const body = await parseApiResponse(res);
  return body.data || null;
}

export async function listTodayNotificationIntents(jwt, targetDate = null) {
  const dateQuery = targetDate ? `?date=${encodeURIComponent(targetDate)}` : "";
  const res = await fetch(`${API_BASE_URL}/api/notifications/intents${dateQuery}`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });
  const payload = await parseApiResponse(res);
  return payload.data || [];
}
