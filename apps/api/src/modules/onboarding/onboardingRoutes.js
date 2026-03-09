import { notFound } from "../../lib/http.js";

export async function handleOnboardingRoutes(req, res, url, controller) {
  const pathname = url.pathname;
  const method = req.method || "GET";

  if (method === "POST" && pathname === "/api/onboarding/complete") {
    return controller.complete(req, res);
  }

  return notFound(res);
}
