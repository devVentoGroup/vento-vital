export class OnboardingService {
  constructor({ rpcClient }) {
    this.rpc = rpcClient;
  }

  async complete({ token, payload }) {
    const safePayload = payload || {};
    const sportsProfile = safePayload.sports_profile;

    if (sportsProfile && typeof sportsProfile === "object" && !Array.isArray(sportsProfile)) {
      await this.rpc.call("upsert_sports_profile", { p_payload: sportsProfile }, token);
    }

    const onboardingResult = await this.rpc.call(
      "create_initial_bundle_from_onboarding",
      { p_payload: safePayload },
      token
    );

    let sportTemplatesResult = null;
    try {
      sportTemplatesResult = await this.rpc.call(
        "apply_sport_templates_from_profile",
        { p_objective: safePayload.objective ?? null },
        token
      );
    } catch (error) {
      const message = String(error?.message || error || "");
      if (!message.includes("apply_sport_templates_from_profile")) {
        throw error;
      }
    }

    if (onboardingResult && typeof onboardingResult === "object" && !Array.isArray(onboardingResult)) {
      return {
        ...onboardingResult,
        sport_templates: sportTemplatesResult,
      };
    }

    return {
      onboarding_result: onboardingResult,
      sport_templates: sportTemplatesResult,
    };
  }
}
