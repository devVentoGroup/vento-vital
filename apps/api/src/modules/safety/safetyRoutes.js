import { notFound } from "../../lib/http.js";

export async function handleSafetyRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "POST" && pathname === "/api/safety/intake") {
    return controller.submitIntake(req, res);
  }

  if (method === "GET" && pathname === "/api/safety/status") {
    return controller.getStatus(req, res);
  }

  return notFound(res);
}
