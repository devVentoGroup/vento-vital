import { readJsonBody, sendJson } from "../../lib/http.js";
import { extractBearerToken } from "../../lib/jwt.js";

export class NotificationsController {
  constructor({ service }) {
    this.service = service;
  }

  async listPlans(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const data = await this.service.listPlans({ token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async upsertPlan(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const data = await this.service.upsertPlan({
        token,
        taskType: body.task_type,
        schedule: body.schedule,
        enabled: body.enabled
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async getTodayIntents(req, res, url) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const date = url.searchParams.get("date");
      const data = await this.service.getTodayIntents({ token, date });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
