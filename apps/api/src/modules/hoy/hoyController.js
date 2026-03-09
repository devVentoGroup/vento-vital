import { createHttpError, readJsonBody, sendJson } from "../../lib/http.js";

const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function requireAuth(req) {
  const auth = req.headers.authorization || "";
  if (!auth.startsWith("Bearer ")) return null;
  return auth.slice("Bearer ".length).trim();
}

function ensureTaskId(taskId) {
  if (!UUID_RE.test(taskId)) {
    throw createHttpError(400, "Invalid task id");
  }
}

export class HoyController {
  constructor({ service }) {
    this.service = service;
  }

  async getToday(req, res, url) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const date = url.searchParams.get("date");
      if (date && !ISO_DATE_RE.test(date)) {
        throw createHttpError(400, "Invalid date format. Expected YYYY-MM-DD");
      }
      const data = await this.service.listTodayTasks({ date, token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async getFeed(req, res, url) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const date = url.searchParams.get("date");
      if (date && !ISO_DATE_RE.test(date)) {
        throw createHttpError(400, "Invalid date format. Expected YYYY-MM-DD");
      }
      const data = await this.service.listTodayFeed({ date, token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async complete(req, res, taskId) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      ensureTaskId(taskId);
      const body = await readJsonBody(req);
      const data = await this.service.completeTask({
        taskId,
        completionPayload: body.completion_payload || {},
        token
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async snooze(req, res, taskId) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      ensureTaskId(taskId);
      const body = await readJsonBody(req);
      if (!body.snooze_until) {
        throw createHttpError(400, "snooze_until is required");
      }
      const data = await this.service.snoozeTask({
        taskId,
        snoozeUntilIso: body.snooze_until,
        token
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async reprogram(req, res, taskId) {
    const token = requireAuth(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      ensureTaskId(taskId);
      const body = await readJsonBody(req);
      if (!body.new_date || !ISO_DATE_RE.test(body.new_date)) {
        throw createHttpError(400, "new_date is required in YYYY-MM-DD format");
      }
      const data = await this.service.reprogramTask({
        taskId,
        newDate: body.new_date,
        token
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
