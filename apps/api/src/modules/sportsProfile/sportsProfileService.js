import { createHttpError } from "../../lib/http.js";

export class SportsProfileService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  async getMine({ token }) {
    return this.rpc.call("get_sports_profile", {}, token);
  }

  async updateMine({ token, payload }) {
    if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
      throw createHttpError(400, "payload must be an object");
    }
    return this.rpc.call("upsert_sports_profile", { p_payload: payload }, token);
  }
}
