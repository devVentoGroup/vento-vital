export class HoyService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  withUiHints(feedRows = []) {
    return feedRows.map((row) => {
      const score = Number(row?.priority_score || 0);
      const tier = score >= 85 ? "critical" : score >= 65 ? "high" : score >= 45 ? "medium" : "low";
      const reasonText = row?.reason_text || "Prioridad calculada por contexto del dia.";
      return {
        ...row,
        ui_priority_tier: tier,
        why_short: reasonText.length > 110 ? `${reasonText.slice(0, 107)}...` : reasonText,
        why_long: reasonText,
        recommended_action: score >= 80 ? "haz_ahora" : score >= 55 ? "haz_hoy" : "planifica_bloque"
      };
    });
  }

  listTodayTasks({ date, token }) {
    const body = date ? { p_target_date: date } : {};
    return this.rpc.call("today_tasks", body, token);
  }

  listTodayFeed({ date, token }) {
    const body = date ? { p_target_date: date } : {};
    return this.rpc.call("today_feed", body, token).then((rows) => this.withUiHints(rows));
  }

  completeTask({ taskId, completionPayload, token }) {
    return this.rpc.call(
      "complete_task_instance",
      {
        p_task_instance_id: taskId,
        p_completion_payload: completionPayload || {}
      },
      token
    );
  }

  snoozeTask({ taskId, snoozeUntilIso, token }) {
    return this.rpc.call(
      "snooze_task_instance",
      {
        p_task_instance_id: taskId,
        p_snooze_until: snoozeUntilIso
      },
      token
    );
  }

  reprogramTask({ taskId, newDate, token }) {
    return this.rpc.call(
      "reprogram_task_instance",
      {
        p_task_instance_id: taskId,
        p_new_date: newDate
      },
      token
    );
  }
}
