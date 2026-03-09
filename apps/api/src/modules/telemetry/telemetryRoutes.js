import { notFound } from "../../lib/http.js";

export async function handleTelemetryRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "POST" && pathname === "/api/telemetry/track") {
    return controller.track(req, res);
  }

  if (method === "POST" && pathname === "/api/telemetry/decision") {
    return controller.trackDecision(req, res);
  }

  if (method === "GET" && pathname === "/api/telemetry/decisions") {
    return controller.listDecisions(req, res, url);
  }

  return notFound(res);
}
