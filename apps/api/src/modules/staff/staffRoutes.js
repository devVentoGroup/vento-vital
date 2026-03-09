import { notFound } from "../../lib/http.js";

export async function handleStaffRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/staff/football-presets") {
    return controller.listPresets(req, res);
  }

  if (method === "POST" && pathname === "/api/staff/football-presets/apply") {
    return controller.applyPreset(req, res);
  }

  if (method === "GET" && pathname === "/api/staff/squad-weekly-overview") {
    return controller.getWeeklyOverview(req, res, url);
  }

  return notFound(res);
}
