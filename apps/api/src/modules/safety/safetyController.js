import { readJsonBody, sendJson } from "../../lib/http.js";
import { extractBearerToken } from "../../lib/jwt.js";

export class SafetyController {
  constructor({ service }) {
    this.service = service;
  }

  async submitIntake(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const data = await this.service.submitIntake({
        token,
        payload: body.payload || {}
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async getStatus(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const data = await this.service.getStatus({ token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
