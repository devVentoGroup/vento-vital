import { createHttpError } from "../../lib/http.js";

export class NutritionService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  getProfile({ token }) {
    return this.rpc.call("get_nutrition_profile_v1", {}, token);
  }

  upsertProfile({ token, payload }) {
    if (!payload || typeof payload !== "object") {
      throw createHttpError(400, "payload must be an object");
    }
    return this.rpc.call("upsert_nutrition_profile_v1", { p_payload: payload }, token);
  }

  upsertDailyLog({ token, inputDate, payload }) {
    return this.rpc.call(
      "upsert_daily_nutrition_log_v1",
      {
        p_input_date: inputDate || null,
        p_payload: payload || {}
      },
      token
    );
  }

  listDailyLogs({ token, from, to }) {
    return this.rpc.call(
      "list_daily_nutrition_logs_v1",
      {
        p_from: from || null,
        p_to: to || null
      },
      token
    );
  }
}

