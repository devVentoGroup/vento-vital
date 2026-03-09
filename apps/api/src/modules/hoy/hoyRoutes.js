import { notFound } from "../../lib/http.js";

export async function handleHoyRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "GET" && pathname === "/api/hoy") {
    return controller.getToday(req, res, url);
  }

  if (method === "GET" && pathname === "/api/hoy/feed") {
    return controller.getFeed(req, res, url);
  }

  const completeMatch = pathname.match(/^\/api\/hoy\/([^/]+)\/complete$/);
  if (method === "POST" && completeMatch) {
    return controller.complete(req, res, completeMatch[1]);
  }

  const snoozeMatch = pathname.match(/^\/api\/hoy\/([^/]+)\/snooze$/);
  if (method === "POST" && snoozeMatch) {
    return controller.snooze(req, res, snoozeMatch[1]);
  }

  const reprogramMatch = pathname.match(/^\/api\/hoy\/([^/]+)\/reprogram$/);
  if (method === "POST" && reprogramMatch) {
    return controller.reprogram(req, res, reprogramMatch[1]);
  }

  return notFound(res);
}
