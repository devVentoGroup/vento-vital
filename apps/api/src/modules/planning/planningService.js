export class PlanningService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  getWeeklyPlan({ weekStart, objective, token }) {
    const body = {};
    if (weekStart) body.p_week_start = weekStart;
    if (objective) body.p_dominant_objective = objective;
    return this.rpc.call("plan_weekly_fused_schedule", body, token);
  }

  getCycleAdjustment({ date, token }) {
    const body = date ? { p_target_date: date } : {};
    return this.rpc.call("plan_cycle_adjustment", body, token);
  }
}
