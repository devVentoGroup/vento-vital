import { notFound } from "../../lib/http.js";

export async function handleWearRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/wear/hoy") {
    return controller.getHoySnapshot(req, res, url);
  }

  return notFound(res);
}
