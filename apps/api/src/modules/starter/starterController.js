import { readJsonBody, sendJson } from "../../lib/http.js";
import { extractBearerToken } from "../../lib/jwt.js";

export class StarterController {
  constructor({ service }) {
    this.service = service;
  }

  async listCatalog(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const data = await this.service.listCatalog({ token });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }

  async createProgram(req, res) {
    const token = extractBearerToken(req);
    if (!token) return sendJson(res, 401, { error: "Missing bearer token" });
    try {
      const body = await readJsonBody(req);
      const data = await this.service.createProgram({
        token,
        starterKey: body.starter_key,
        programName: body.program_name
      });
      return sendJson(res, 200, { data });
    } catch (err) {
      return sendJson(res, err.status || 500, { error: err.message, details: err.details || null });
    }
  }
}
