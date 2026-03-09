import { notFound } from "../../lib/http.js";

export async function handleAiRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "POST" && pathname === "/api/ai/plan/preview") {
    return controller.previewPlan(req, res, url);
  }

  if (method === "POST" && pathname === "/api/ai/plan/apply") {
    return controller.applyPlan(req, res);
  }

  if (method === "POST" && pathname === "/api/ai/hoy/adjust") {
    return controller.adjustHoy(req, res, url);
  }

  return notFound(res);
}

