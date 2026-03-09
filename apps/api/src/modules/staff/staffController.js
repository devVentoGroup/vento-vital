import { createHttpError, readJsonBody, sendJson } from "../../lib/http.js";

const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function requireAuth(req) {
  const auth = req.headers.authorization || "";
  if (!auth.startsWith("Bearer ")) return null;
  return auth.slice("Bearer ".length).trim();
}

export class StaffController {
  constructor({ service }) {
    this.service = service;
  }

  async listPresets(req, res) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const data = await this.service.listFootballPresets({ token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async applyPreset(req, res) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const presetKey = String(body?.preset_key || "").trim();
      if (!presetKey) throw createHttpError(400, "preset_key is required");
      const data = await this.service.applyFootballPreset({ presetKey, token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async getWeeklyOverview(req, res, url) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const squadId = String(url.searchParams.get("squad_id") || "").trim();
      const weekStart = url.searchParams.get("week_start");
      if (!UUID_RE.test(squadId)) {
        throw createHttpError(400, "squad_id is required and must be UUID");
      }
      if (weekStart && !ISO_DATE_RE.test(weekStart)) {
        throw createHttpError(400, "Invalid week_start format. Expected YYYY-MM-DD");
      }
      const data = await this.service.getWeeklySquadOverview({ squadId, weekStart, token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
