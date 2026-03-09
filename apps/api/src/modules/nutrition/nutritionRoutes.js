import { notFound } from "../../lib/http.js";

export async function handleNutritionRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/nutrition/profile") {
    return controller.getProfile(req, res);
  }

  if (method === "PUT" && pathname === "/api/nutrition/profile") {
    return controller.putProfile(req, res);
  }

  if (method === "PUT" && pathname === "/api/nutrition/log") {
    return controller.putDailyLog(req, res);
  }

  if (method === "GET" && pathname === "/api/nutrition/logs") {
    return controller.listDailyLogs(req, res, url);
  }

  return notFound(res);
}

