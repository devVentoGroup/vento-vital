import { createHttpError, sendJson } from "../../lib/http.js";

const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

function requireAuth(req) {
  const auth = req.headers.authorization || "";
  if (!auth.startsWith("Bearer ")) return null;
  return auth.slice("Bearer ".length).trim();
}

export class PlanningController {
  constructor({ service }) {
    this.service = service;
  }

  async getWeekly(req, res, url) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });

    try {
      const weekStart = url.searchParams.get("week_start");
      const objective = url.searchParams.get("objective");

      if (weekStart && !ISO_DATE_RE.test(weekStart)) {
        throw createHttpError(400, "Invalid week_start format. Expected YYYY-MM-DD");
      }

      const data = await this.service.getWeeklyPlan({
        weekStart,
        objective,
        token,
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, {
        error: err.message,
        details: err.details || null,
      });
    }
  }

  async getCycle(req, res, url) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });

    try {
      const date = url.searchParams.get("date");
      if (date && !ISO_DATE_RE.test(date)) {
        throw createHttpError(400, "Invalid date format. Expected YYYY-MM-DD");
      }
      const data = await this.service.getCycleAdjustment({ date, token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, {
        error: err.message,
        details: err.details || null,
      });
    }
  }
}
