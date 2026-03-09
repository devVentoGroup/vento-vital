export class StaffService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  listFootballPresets({ token }) {
    return this.rpc.call("list_football_presets", {}, token);
  }

  applyFootballPreset({ presetKey, token }) {
    return this.rpc.call("apply_football_preset", { p_preset_key: presetKey }, token);
  }

  getWeeklySquadOverview({ squadId, weekStart, token }) {
    const body = { p_squad_id: squadId };
    if (weekStart) body.p_week_start = weekStart;
    return this.rpc.call("staff_weekly_squad_overview", body, token);
  }
}
