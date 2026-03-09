function toDateOnlyISO(date) {
  return date.toISOString().slice(0, 10);
}

function startOfTodayLocal() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

export class SummaryService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  async getWeeklySummary({ token, weekStart = null }) {
    const baseDate = weekStart ? new Date(weekStart) : startOfTodayLocal();
    const day = baseDate.getDay();
    const diffToMonday = day === 0 ? 6 : day - 1;
    baseDate.setDate(baseDate.getDate() - diffToMonday);

    const dates = Array.from({ length: 7 }, (_, i) => {
      const d = new Date(baseDate);
      d.setDate(baseDate.getDate() + i);
      return toDateOnlyISO(d);
    });

    const rows = await Promise.all(
      dates.map(async (date) => {
        const feed = await this.rpc.call("today_feed", { p_target_date: date }, token).catch(() => []);
        const total = feed.length;
        const completed = feed.filter((t) => t.status === "completed").length;
        const pct = total > 0 ? Math.round((completed / total) * 100) : 0;
        const modules = feed.reduce((acc, t) => {
          const key = t.module_key || "training";
          if (!acc[key]) acc[key] = { total: 0, completed: 0 };
          acc[key].total += 1;
          if ((t.status || "").toLowerCase() === "completed") acc[key].completed += 1;
          return acc;
        }, {});
        return { date, total, completed, pct, modules };
      })
    );

    const moduleAgg = {};
    rows.forEach((r) => {
      Object.entries(r.modules || {}).forEach(([k, v]) => {
        if (!moduleAgg[k]) moduleAgg[k] = { total: 0, completed: 0, pct: 0 };
        moduleAgg[k].total += v.total;
        moduleAgg[k].completed += v.completed;
      });
    });
    Object.values(moduleAgg).forEach((m) => {
      m.pct = m.total > 0 ? Math.round((m.completed / m.total) * 100) : 0;
    });

    const planning = await this.rpc
      .call("plan_weekly_fused_schedule", { p_week_start: toDateOnlyISO(baseDate) }, token)
      .catch(() => []);
    const cycle = await this.rpc.call("plan_cycle_adjustment", { p_target_date: toDateOnlyISO(startOfTodayLocal()) }, token).catch(() => []);
    const nutritionProfile = await this.rpc.call("get_nutrition_profile_v1", {}, token).catch(() => null);

    return {
      week_start: toDateOnlyISO(baseDate),
      trend: rows,
      module_trend: moduleAgg,
      planning_rows: Array.isArray(planning) ? planning : [],
      cycle_adjustments: Array.isArray(cycle) ? cycle : [],
      nutrition_profile: nutritionProfile || null
    };
  }
}

