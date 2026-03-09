const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || "http://localhost:8787";

async function parseApiResponse(res) {
  const payload = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(payload.error || "Error en API HOY");
  }
  return payload;
}

export async function getTodayTasks(jwt, targetDate = null) {
  const dateQuery = targetDate ? `?date=${encodeURIComponent(targetDate)}` : "";
  const res = await fetch(`${API_BASE_URL}/api/hoy${dateQuery}`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });

  const payload = await parseApiResponse(res);
  return payload.data || [];
}

export async function getTodayFeed(jwt, targetDate = null) {
  const dateQuery = targetDate ? `?date=${encodeURIComponent(targetDate)}` : "";
  const res = await fetch(`${API_BASE_URL}/api/hoy/feed${dateQuery}`, {
    headers: {
      authorization: `Bearer ${jwt}`
    }
  });

  const payload = await parseApiResponse(res);
  return payload.data || [];
}

export async function completeTask(jwt, taskId, completionPayload = {}) {
  const res = await fetch(`${API_BASE_URL}/api/hoy/${taskId}/complete`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({ completion_payload: completionPayload })
  });

  const payload = await parseApiResponse(res);
  return payload.data;
}

export async function snoozeTask(jwt, taskId, snoozeUntilIso) {
  const res = await fetch(`${API_BASE_URL}/api/hoy/${taskId}/snooze`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({ snooze_until: snoozeUntilIso })
  });

  const payload = await parseApiResponse(res);
  return payload.data;
}

export async function reprogramTask(jwt, taskId, newDate) {
  const res = await fetch(`${API_BASE_URL}/api/hoy/${taskId}/reprogram`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${jwt}`,
      "content-type": "application/json"
    },
    body: JSON.stringify({ new_date: newDate })
  });

  const payload = await parseApiResponse(res);
  return payload.data;
}
