import { notFound } from "../../lib/http.js";

export async function handlePlanningRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/planning/weekly") {
    return controller.getWeekly(req, res, url);
  }

  if (method === "GET" && pathname === "/api/planning/cycle") {
    return controller.getCycle(req, res, url);
  }

  return notFound(res);
}
