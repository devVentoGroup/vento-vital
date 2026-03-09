import { notFound } from "../../lib/http.js";

export async function handleProfileRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (pathname !== "/api/profile") return notFound(res);

  if (method === "GET") {
    return controller.getProfile(req, res);
  }

  if (method === "PUT") {
    return controller.putProfile(req, res);
  }

  return notFound(res);
}
