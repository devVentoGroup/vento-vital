import * as SecureStore from "expo-secure-store";

const PREFIX = "vento_vital_onboarding_done_v1_";
const CURRENT_VERSION = 2;

function getKey(email) {
  const rawEmail = String(email || "").trim().toLowerCase();
  const safeEmail = rawEmail.replace(/[^a-z0-9._-]/g, "_");
  return `${PREFIX}${safeEmail || "anonymous"}`;
}

export async function loadOnboardingDone(email) {
  const raw = await SecureStore.getItemAsync(getKey(email));
  return raw === "1";
}

export async function saveOnboardingDone(email, done = true) {
  await SecureStore.setItemAsync(getKey(email), done ? "1" : "0");
}

export async function loadOnboardingV2Done(email) {
  const raw = await SecureStore.getItemAsync(getKey(email));
  if (!raw) return false;
  if (raw === "1") return false;
  try {
    const parsed = JSON.parse(raw);
    return Boolean(parsed?.done && Number(parsed?.version) >= CURRENT_VERSION);
  } catch {
    return false;
  }
}

export async function saveOnboardingV2Done(email, done = true) {
  await SecureStore.setItemAsync(
    getKey(email),
    JSON.stringify({
      version: CURRENT_VERSION,
      done: Boolean(done)
    })
  );
}
