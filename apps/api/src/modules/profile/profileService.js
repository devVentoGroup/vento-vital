import { createHttpError } from "../../lib/http.js";

const PROFILE_CONTEXTS = new Set(["personal", "employee"]);
const COMPETITION_MODES = new Set(["private", "friends", "team", "public"]);

function normalizeText(v) {
  return typeof v === "string" ? v.trim() : "";
}

export class ProfileService {
  constructor({ tableClient }) {
    this.table = tableClient;
  }

  async getProfile({ token }) {
    return this.table.getUserProfile(token);
  }

  async saveProfile({ token, userId, payload }) {
    const displayName = normalizeText(payload.display_name);
    const timezone = normalizeText(payload.timezone);
    const profileContext = normalizeText(payload.profile_context) || "personal";
    const competitionMode = normalizeText(payload.competition_mode) || "private";

    if (!PROFILE_CONTEXTS.has(profileContext)) {
      throw createHttpError(400, "Invalid profile_context");
    }
    if (!COMPETITION_MODES.has(competitionMode)) {
      throw createHttpError(400, "Invalid competition_mode");
    }
    if (timezone.length === 0) {
      throw createHttpError(400, "timezone is required");
    }

    return this.table.upsertUserProfile(token, {
      user_id: userId,
      display_name: displayName || null,
      timezone,
      profile_context: profileContext,
      competition_mode: competitionMode
    });
  }
}
