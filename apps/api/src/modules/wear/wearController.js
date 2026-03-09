import { sendJson } from "../../lib/http.js";
import { toWearHoySnapshot } from "@vento-vital/contracts";

function requireAuth(req) {
  const auth = req.headers.authorization || "";
  if (!auth.startsWith("Bearer ")) return null;
  return auth.slice("Bearer ".length).trim();
}

export class WearController {
  constructor({ hoyService }) {
    this.hoyService = hoyService;
  }

  async getHoySnapshot(req, res, url) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const date = url.searchParams.get("date");
      const tasks = await this.hoyService.listTodayTasks({ date, token });
      return sendJson(res, 200, { data: toWearHoySnapshot(tasks) });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
