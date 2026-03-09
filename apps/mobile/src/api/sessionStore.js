import * as SecureStore from "expo-secure-store";

const SESSION_KEY = "vento_vital_session_v1";

export async function saveSession(session) {
  if (!session?.accessToken) return;
  await SecureStore.setItemAsync(SESSION_KEY, JSON.stringify(session));
}

export async function loadSession() {
  const raw = await SecureStore.getItemAsync(SESSION_KEY);
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    if (!parsed?.accessToken) return null;
    return parsed;
  } catch {
    return null;
  }
}

export async function clearSession() {
  await SecureStore.deleteItemAsync(SESSION_KEY);
}
