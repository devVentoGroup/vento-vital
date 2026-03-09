import { createHttpError } from "../../lib/http.js";

function normalizeStarterKey(value) {
  return typeof value === "string" ? value.trim() : "";
}

function normalizeProgramName(value) {
  if (typeof value !== "string") return null;
  const next = value.trim();
  return next.length > 0 ? next : null;
}

export class StarterService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  listCatalog({ token }) {
    return this.rpc.call("list_starter_programs", {}, token);
  }

  createProgram({ token, starterKey, programName }) {
    const key = normalizeStarterKey(starterKey);
    if (!key) {
      throw createHttpError(400, "starter_key is required");
    }
    return this.rpc.call(
      "create_program_from_starter",
      {
        p_starter_key: key,
        p_program_name: normalizeProgramName(programName)
      },
      token
    );
  }
}
