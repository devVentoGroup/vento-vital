import { createHttpError, sendJson } from "../../lib/http.js";
import { extractBearerToken } from "../../lib/jwt.js";

const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

export class SummaryController {
  constructor({ service }) {
    this.service = service;
  }

  async getWeekly(req, res, url) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });

    try {
      const weekStart = url.searchParams.get("week_start");
      if (weekStart && !ISO_DATE_RE.test(weekStart)) {
        throw createHttpError(400, "Invalid week_start format. Expected YYYY-MM-DD");
      }
      const data = await this.service.getWeeklySummary({ token, weekStart: weekStart || null });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}

