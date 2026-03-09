import { notFound } from "../../lib/http.js";

export async function handleSummaryRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/summary/weekly") {
    return controller.getWeekly(req, res, url);
  }

  return notFound(res);
}

