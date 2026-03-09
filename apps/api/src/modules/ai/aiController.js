import { createHttpError, readJsonBody, sendJson } from "../../lib/http.js";
import { extractBearerToken } from "../../lib/jwt.js";

const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

export class AiController {
  constructor({ service }) {
    this.service = service;
  }

  async previewPlan(req, res, url) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const date = url.searchParams.get("date");
      if (date && !ISO_DATE_RE.test(date)) {
        throw createHttpError(400, "Invalid date format. Expected YYYY-MM-DD");
      }
      const data = await this.service.previewWeeklyPlan({ token, targetDate: date || null });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async applyPlan(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const proposalPayload = body.proposal_payload || body.payload || null;
      const data = await this.service.applyWeeklyPlan({ token, proposalPayload });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async adjustHoy(req, res, url) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const date = url.searchParams.get("date");
      if (date && !ISO_DATE_RE.test(date)) {
        throw createHttpError(400, "Invalid date format. Expected YYYY-MM-DD");
      }
      const data = await this.service.adjustHoy({ token, targetDate: date || null });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}

