import { notFound } from "../../lib/http.js";

export async function handleStarterRoutes(req, res, _url, controller) {
  const pathname = _url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/starter/catalog") {
    return controller.listCatalog(req, res);
  }

  if (method === "POST" && pathname === "/api/starter/create") {
    return controller.createProgram(req, res);
  }

  return notFound(res);
}
