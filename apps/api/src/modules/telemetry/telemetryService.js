import { createHttpError } from "../../lib/http.js";

function normalizeText(value, fallback = "") {
  if (typeof value !== "string") return fallback;
  const next = value.trim();
  return next.length > 0 ? next : fallback;
}

function normalizeLimit(value, fallback = 50) {
  if (value === null || value === undefined || value === "") return fallback;
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.max(1, Math.min(200, Math.trunc(parsed)));
}

export class TelemetryService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  async track({ token, eventName, payload, source, occurredAt, eventVersion }) {
    const name = normalizeText(eventName);
    if (!name) {
      throw createHttpError(400, "event_name is required");
    }

    return this.rpc.call(
      "track_event",
      {
        p_event_name: name,
        p_payload: payload || {},
        p_source: normalizeText(source, "app"),
        p_occurred_at: normalizeText(occurredAt) || new Date().toISOString(),
        p_event_version: normalizeText(eventVersion, "v1")
      },
      token
    );
  }

  async trackDecision({ token, eventName, reasonCode, reasonText, payload, source, occurredAt, eventVersion }) {
    const name = normalizeText(eventName);
    const code = normalizeText(reasonCode);
    const text = normalizeText(reasonText);

    if (!name) throw createHttpError(400, "event_name is required");
    if (!code) throw createHttpError(400, "reason_code is required");
    if (!text) throw createHttpError(400, "reason_text is required");

    return this.rpc.call(
      "track_decision_event",
      {
        p_event_name: name,
        p_reason_code: code,
        p_reason_text: text,
        p_payload: payload || {},
        p_source: normalizeText(source, "app"),
        p_occurred_at: normalizeText(occurredAt) || new Date().toISOString(),
        p_event_version: normalizeText(eventVersion, "v1")
      },
      token
    );
  }

  listDecisionEvents({ token, limit, eventName }) {
    return this.rpc.call(
      "list_decision_events",
      {
        p_limit: normalizeLimit(limit, 50),
        p_event_name: normalizeText(eventName) || null
      },
      token
    );
  }
}
