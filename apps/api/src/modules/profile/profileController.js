import { createHttpError, readJsonBody, sendJson } from "../../lib/http.js";
import { extractBearerToken, getJwtSub } from "../../lib/jwt.js";

export class ProfileController {
  constructor({ service }) {
    this.service = service;
  }

  async getProfile(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const data = await this.service.getProfile({ token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async putProfile(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const userId = getJwtSub(token);
      if (!userId) throw createHttpError(401, "Invalid JWT subject");
      const body = await readJsonBody(req);
      const data = await this.service.saveProfile({
        token,
        userId,
        payload: body
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
