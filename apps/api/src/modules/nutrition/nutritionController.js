import { createHttpError, readJsonBody, sendJson } from "../../lib/http.js";
import { extractBearerToken } from "../../lib/jwt.js";

const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

export class NutritionController {
  constructor({ service }) {
    this.service = service;
  }

  async getProfile(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const data = await this.service.getProfile({ token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async putProfile(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const data = await this.service.upsertProfile({ token, payload: body.payload || {} });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async putDailyLog(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const inputDate = body.input_date || null;
      if (inputDate && !ISO_DATE_RE.test(inputDate)) {
        throw createHttpError(400, "Invalid input_date format. Expected YYYY-MM-DD");
      }
      const data = await this.service.upsertDailyLog({
        token,
        inputDate,
        payload: body.payload || {}
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async listDailyLogs(req, res, url) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const from = url.searchParams.get("from");
      const to = url.searchParams.get("to");
      if (from && !ISO_DATE_RE.test(from)) {
        throw createHttpError(400, "Invalid from format. Expected YYYY-MM-DD");
      }
      if (to && !ISO_DATE_RE.test(to)) {
        throw createHttpError(400, "Invalid to format. Expected YYYY-MM-DD");
      }
      const data = await this.service.listDailyLogs({ token, from: from || null, to: to || null });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}

