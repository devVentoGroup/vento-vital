import { notFound } from "../../lib/http.js";

export async function handleSportsProfileRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (pathname !== "/api/sports-profile/me") return notFound(res);

  if (method === "GET") {
    return controller.getMine(req, res);
  }

  if (method === "PUT") {
    return controller.updateMine(req, res);
  }

  return notFound(res);
}
