import { createHttpError } from "../../lib/http.js";

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

function normalizeTaskType(value) {
  return typeof value === "string" ? value.trim() : "";
}

export class NotificationsService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  listPlans({ token }) {
    return this.rpc.call("list_notification_plans", {}, token);
  }

  upsertPlan({ token, taskType, schedule, enabled = true }) {
    const nextTaskType = normalizeTaskType(taskType);
    if (!nextTaskType) {
      throw createHttpError(400, "task_type is required");
    }
    if (!schedule || typeof schedule !== "object") {
      throw createHttpError(400, "schedule is required");
    }

    return this.rpc.call(
      "upsert_notification_plan",
      {
        p_task_type: nextTaskType,
        p_schedule: schedule,
        p_enabled: Boolean(enabled)
      },
      token
    );
  }

  getTodayIntents({ token, date }) {
    if (date && !DATE_RE.test(date)) {
      throw createHttpError(400, "Invalid date format. Expected YYYY-MM-DD");
    }
    return this.rpc.call("today_notification_intents", date ? { p_target_date: date } : {}, token);
  }
}
