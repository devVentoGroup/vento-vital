import { notFound } from "../../lib/http.js";

export async function handleNotificationsRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/notifications/plans") {
    return controller.listPlans(req, res);
  }

  if (method === "POST" && pathname === "/api/notifications/plans/upsert") {
    return controller.upsertPlan(req, res);
  }

  if (method === "GET" && pathname === "/api/notifications/intents") {
    return controller.getTodayIntents(req, res, url);
  }

  return notFound(res);
}
