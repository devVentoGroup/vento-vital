import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const required = ["SUPABASE_URL", "SUPABASE_ANON_KEY"];

function parseEnvFile(content) {
  const out = {};
  const lines = content.split(/\r?\n/);

  for (const raw of lines) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;

    const eq = line.indexOf("=");
    if (eq <= 0) continue;

    const key = line.slice(0, eq).trim();
    let value = line.slice(eq + 1).trim();
    if ((value.startsWith("\"") && value.endsWith("\"")) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    out[key] = value;
  }

  return out;
}

function loadEnvFiles() {
  const here = dirname(fileURLToPath(import.meta.url));
  const root = resolve(here, "../../../../");
  const files = [resolve(root, ".env"), resolve(root, ".env.local")];
  const merged = {};

  for (const file of files) {
    if (!existsSync(file)) continue;
    Object.assign(merged, parseEnvFile(readFileSync(file, "utf8")));
  }

  for (const [key, value] of Object.entries(merged)) {
    if (process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

export function loadEnv() {
  loadEnvFiles();

  if (!process.env.SUPABASE_URL && process.env.EXPO_PUBLIC_SUPABASE_URL) {
    process.env.SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL;
  }
  if (!process.env.SUPABASE_ANON_KEY && process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY) {
    process.env.SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;
  }

  const missing = required.filter((name) => !process.env[name]);
  if (missing.length > 0) {
    throw new Error(`Missing env vars: ${missing.join(", ")}`);
  }

  return {
    port: Number(process.env.PORT || 8787),
    supabaseUrl: process.env.SUPABASE_URL,
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY,
    supabaseRpcSchema: process.env.SUPABASE_RPC_SCHEMA || "vital",
    openAiApiKey: process.env.OPENAI_API_KEY || "",
    openAiModel: process.env.OPENAI_MODEL || "gpt-4.1-mini",
    aiPromptVersion: process.env.AI_PROMPT_VERSION || "v1"
  };
}
