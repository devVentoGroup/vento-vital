import { readJsonBody, sendJson } from "../../lib/http.js";
import { extractBearerToken } from "../../lib/jwt.js";

export class TelemetryController {
  constructor({ service }) {
    this.service = service;
  }

  async track(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const data = await this.service.track({
        token,
        eventName: body.event_name,
        payload: body.payload,
        source: body.source,
        occurredAt: body.occurred_at,
        eventVersion: body.event_version
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async trackDecision(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const data = await this.service.trackDecision({
        token,
        eventName: body.event_name,
        reasonCode: body.reason_code,
        reasonText: body.reason_text,
        payload: body.payload,
        source: body.source,
        occurredAt: body.occurred_at,
        eventVersion: body.event_version
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async listDecisions(req, res, url) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const data = await this.service.listDecisionEvents({
        token,
        limit: url.searchParams.get("limit"),
        eventName: url.searchParams.get("event_name")
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
