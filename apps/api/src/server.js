import { createServer } from "node:http";
import { randomUUID } from "node:crypto";
import { loadEnv } from "./config/env.js";
import { sendJson } from "./lib/http.js";
import { SupabaseRpcClient } from "./lib/supabaseRpcClient.js";
import { SupabaseTableClient } from "./lib/supabaseTableClient.js";
import { HoyService } from "./modules/hoy/hoyService.js";
import { HoyController } from "./modules/hoy/hoyController.js";
import { handleHoyRoutes } from "./modules/hoy/hoyRoutes.js";
import { WearController } from "./modules/wear/wearController.js";
import { handleWearRoutes } from "./modules/wear/wearRoutes.js";
import { ProfileService } from "./modules/profile/profileService.js";
import { ProfileController } from "./modules/profile/profileController.js";
import { handleProfileRoutes } from "./modules/profile/profileRoutes.js";
import { NotificationsService } from "./modules/notifications/notificationsService.js";
import { NotificationsController } from "./modules/notifications/notificationsController.js";
import { handleNotificationsRoutes } from "./modules/notifications/notificationsRoutes.js";
import { StarterService } from "./modules/starter/starterService.js";
import { StarterController } from "./modules/starter/starterController.js";
import { handleStarterRoutes } from "./modules/starter/starterRoutes.js";
import { ModulesService } from "./modules/modules/modulesService.js";
import { ModulesController } from "./modules/modules/modulesController.js";
import { handleModulesRoutes } from "./modules/modules/modulesRoutes.js";
import { SafetyService } from "./modules/safety/safetyService.js";
import { SafetyController } from "./modules/safety/safetyController.js";
import { handleSafetyRoutes } from "./modules/safety/safetyRoutes.js";
import { OnboardingService } from "./modules/onboarding/onboardingService.js";
import { OnboardingController } from "./modules/onboarding/onboardingController.js";
import { handleOnboardingRoutes } from "./modules/onboarding/onboardingRoutes.js";
import { TelemetryService } from "./modules/telemetry/telemetryService.js";
import { TelemetryController } from "./modules/telemetry/telemetryController.js";
import { handleTelemetryRoutes } from "./modules/telemetry/telemetryRoutes.js";
import { SportsProfileService } from "./modules/sportsProfile/sportsProfileService.js";
import { SportsProfileController } from "./modules/sportsProfile/sportsProfileController.js";
import { handleSportsProfileRoutes } from "./modules/sportsProfile/sportsProfileRoutes.js";
import { PlanningService } from "./modules/planning/planningService.js";
import { PlanningController } from "./modules/planning/planningController.js";
import { handlePlanningRoutes } from "./modules/planning/planningRoutes.js";
import { StaffService } from "./modules/staff/staffService.js";
import { StaffController } from "./modules/staff/staffController.js";
import { handleStaffRoutes } from "./modules/staff/staffRoutes.js";
import { AiService } from "./modules/ai/aiService.js";
import { AiController } from "./modules/ai/aiController.js";
import { handleAiRoutes } from "./modules/ai/aiRoutes.js";
import { OpenAiClient } from "./lib/openAiClient.js";
import { SummaryService } from "./modules/summary/summaryService.js";
import { SummaryController } from "./modules/summary/summaryController.js";
import { handleSummaryRoutes } from "./modules/summary/summaryRoutes.js";
import { NutritionService } from "./modules/nutrition/nutritionService.js";
import { NutritionController } from "./modules/nutrition/nutritionController.js";
import { handleNutritionRoutes } from "./modules/nutrition/nutritionRoutes.js";

const env = loadEnv();
const rpcClient = new SupabaseRpcClient({
  supabaseUrl: env.supabaseUrl,
  supabaseAnonKey: env.supabaseAnonKey,
  rpcSchema: env.supabaseRpcSchema
});
const tableClient = new SupabaseTableClient({
  supabaseUrl: env.supabaseUrl,
  supabaseAnonKey: env.supabaseAnonKey,
  schema: env.supabaseRpcSchema
});

const hoyService = new HoyService({ rpcClient });
const hoyController = new HoyController({ service: hoyService });
const wearController = new WearController({ hoyService });
const profileService = new ProfileService({ tableClient });
const profileController = new ProfileController({ service: profileService });
const notificationsService = new NotificationsService({ rpcClient });
const notificationsController = new NotificationsController({ service: notificationsService });
const starterService = new StarterService({ rpcClient });
const starterController = new StarterController({ service: starterService });
const modulesService = new ModulesService({ rpcClient });
const modulesController = new ModulesController({ service: modulesService });
const safetyService = new SafetyService({ rpcClient });
const safetyController = new SafetyController({ service: safetyService });
const onboardingService = new OnboardingService({ rpcClient });
const onboardingController = new OnboardingController({ service: onboardingService });
const telemetryService = new TelemetryService({ rpcClient });
const telemetryController = new TelemetryController({ service: telemetryService });
const sportsProfileService = new SportsProfileService({ rpcClient });
const sportsProfileController = new SportsProfileController({ service: sportsProfileService });
const planningService = new PlanningService({ rpcClient });
const planningController = new PlanningController({ service: planningService });
const staffService = new StaffService({ rpcClient });
const staffController = new StaffController({ service: staffService });
const openAiClient = new OpenAiClient({
  apiKey: env.openAiApiKey,
  model: env.openAiModel,
  promptVersion: env.aiPromptVersion
});
const aiService = new AiService({
  rpcClient,
  openAiClient,
  modelName: env.openAiModel,
  promptVersion: env.aiPromptVersion
});
const aiController = new AiController({ service: aiService });
const summaryService = new SummaryService({ rpcClient });
const summaryController = new SummaryController({ service: summaryService });
const nutritionService = new NutritionService({ rpcClient });
const nutritionController = new NutritionController({ service: nutritionService });

const server = createServer(async (req, res) => {
  const requestId = randomUUID();
  const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);

  try {
    if (req.method === "GET" && url.pathname === "/health") {
      return sendJson(res, 200, { ok: true, service: "vento-vital-api", request_id: requestId });
    }

    if (url.pathname.startsWith("/api/hoy")) {
      return handleHoyRoutes(req, res, url, hoyController);
    }

    if (url.pathname.startsWith("/api/wear")) {
      return handleWearRoutes(req, res, url, wearController);
    }

    if (url.pathname.startsWith("/api/profile")) {
      return handleProfileRoutes(req, res, url, profileController);
    }

    if (url.pathname.startsWith("/api/notifications")) {
      return handleNotificationsRoutes(req, res, url, notificationsController);
    }

    if (url.pathname.startsWith("/api/starter")) {
      return handleStarterRoutes(req, res, url, starterController);
    }

    if (url.pathname.startsWith("/api/modules")) {
      return handleModulesRoutes(req, res, url, modulesController);
    }

    if (url.pathname.startsWith("/api/safety")) {
      return handleSafetyRoutes(req, res, url, safetyController);
    }

    if (url.pathname.startsWith("/api/onboarding")) {
      return handleOnboardingRoutes(req, res, url, onboardingController);
    }

    if (url.pathname.startsWith("/api/telemetry")) {
      return handleTelemetryRoutes(req, res, url, telemetryController);
    }

    if (url.pathname.startsWith("/api/sports-profile")) {
      return handleSportsProfileRoutes(req, res, url, sportsProfileController);
    }

    if (url.pathname.startsWith("/api/planning")) {
      return handlePlanningRoutes(req, res, url, planningController);
    }

    if (url.pathname.startsWith("/api/staff")) {
      return handleStaffRoutes(req, res, url, staffController);
    }

    if (url.pathname.startsWith("/api/ai")) {
      return handleAiRoutes(req, res, url, aiController);
    }

    if (url.pathname.startsWith("/api/summary")) {
      return handleSummaryRoutes(req, res, url, summaryController);
    }

    if (url.pathname.startsWith("/api/nutrition")) {
      return handleNutritionRoutes(req, res, url, nutritionController);
    }

    return sendJson(res, 404, { error: "Not found", request_id: requestId });
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error(`[${requestId}] Unhandled API error`, err);
    return sendJson(res, 500, {
      error: "Internal server error",
      request_id: requestId
    });
  }
});

server.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`Vento Vital API running on http://localhost:${env.port}`);
});
