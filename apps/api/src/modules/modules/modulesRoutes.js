import { notFound } from "../../lib/http.js";

export async function handleModulesRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/modules/catalog") {
    return controller.listCatalog(req, res);
  }

  if (method === "GET" && pathname === "/api/modules/me") {
    return controller.getMine(req, res);
  }

  if (method === "PUT" && pathname === "/api/modules/me") {
    return controller.updateMine(req, res);
  }

  return notFound(res);
}
