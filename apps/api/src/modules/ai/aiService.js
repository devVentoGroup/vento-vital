import { createHttpError } from "../../lib/http.js";

function toShortReason(reasonText) {
  const base = String(reasonText || "").trim();
  if (!base) return "Prioridad calculada por contexto del usuario.";
  return base.length > 120 ? `${base.slice(0, 117)}...` : base;
}

function normalizeFeedUiFields(feedRows = []) {
  return feedRows.map((row) => {
    const score = Number(row?.priority_score || 0);
    const tier = score >= 85 ? "critical" : score >= 65 ? "high" : score >= 45 ? "medium" : "low";
    return {
      ...row,
      ui_priority_tier: tier,
      why_short: toShortReason(row?.reason_text),
      why_long: row?.reason_text || "Prioridad calculada por motor inteligente.",
      recommended_action: score >= 80 ? "haz_ahora" : score >= 55 ? "haz_hoy" : "planifica_bloque"
    };
  });
}

export class AiService {
  constructor({ rpcClient, openAiClient, modelName = "gpt-4.1-mini", promptVersion = "v1" }) {
    this.rpc = rpcClient;
    this.openAi = openAiClient;
    this.modelName = modelName;
    this.promptVersion = promptVersion;
  }

  async getContextBundle({ token, targetDate }) {
    return this.rpc.call(
      "get_ai_context_bundle",
      {
        p_target_date: targetDate || null
      },
      token
    );
  }

  buildDeterministicPreview(contextBundle) {
    const weekly = Array.isArray(contextBundle?.weekly_plan) ? contextBundle.weekly_plan : [];
    const weeklyBlocks = weekly.slice(0, 10).map((row) => ({
      module_key: row.module_key,
      task_type: row.task_type,
      title: row.title,
      estimated_minutes: row.estimated_minutes || 20,
      days: [new Date(row.plan_date).getDay() || 1],
      reason_text: row.interference_note || "Bloque recomendado por plan semanal actual.",
      payload: {
        source: "deterministic_fallback_v1",
        priority_hint: row.priority_hint || 50
      }
    }));

    return {
      summary: "Propuesta generada con fallback deterministico por disponibilidad de IA.",
      confidence_score: 68,
      weekly_blocks: weeklyBlocks,
      hoy_adjustments: []
    };
  }

  async previewWeeklyPlan({ token, targetDate }) {
    const contextBundle = await this.getContextBundle({ token, targetDate });
    let proposal = null;
    let source = "deterministic_fallback_v1";
    let confidence = 68;

    if (this.openAi?.enabled) {
      try {
        proposal = await this.openAi.generateWeeklyPlanProposal({ context: contextBundle });
        source = "openai";
        confidence = Number(proposal?.confidence_score || 72);
      } catch {
        proposal = this.buildDeterministicPreview(contextBundle);
      }
    } else {
      proposal = this.buildDeterministicPreview(contextBundle);
    }

    const saved = await this.rpc.call(
      "create_ai_plan_proposal_v1",
      {
        p_context_payload: contextBundle,
        p_proposal_payload: proposal,
        p_confidence_score: confidence,
        p_model_name: source === "openai" ? this.modelName : source,
        p_prompt_version: this.promptVersion
      },
      token
    );

    await this.rpc.call(
      "log_ai_decision_event",
      {
        p_event_name: "ai_plan_previewed",
        p_reason_code: source === "openai" ? "ai_generation_ok" : "ai_fallback_used",
        p_reason_text:
          source === "openai"
            ? "Se genero propuesta semanal con IA."
            : "Se genero propuesta semanal con fallback deterministico.",
        p_payload: {
          proposal_id: saved?.id || null,
          confidence_score: confidence,
          source
        },
        p_source: "api",
        p_model_name: source === "openai" ? this.modelName : source,
        p_prompt_version: this.promptVersion
      },
      token
    );

    return {
      proposal_id: saved?.id || null,
      source,
      confidence_score: confidence,
      summary: proposal?.summary || "Propuesta generada.",
      weekly_blocks: Array.isArray(proposal?.weekly_blocks) ? proposal.weekly_blocks : [],
      hoy_adjustments: Array.isArray(proposal?.hoy_adjustments) ? proposal.hoy_adjustments : []
    };
  }

  async applyWeeklyPlan({ token, proposalPayload }) {
    if (!proposalPayload || typeof proposalPayload !== "object") {
      throw createHttpError(400, "proposal_payload is required");
    }

    const result = await this.rpc.call(
      "apply_ai_weekly_plan",
      {
        p_payload: proposalPayload
      },
      token
    );

    await this.rpc.call(
      "log_ai_decision_event",
      {
        p_event_name: "ai_plan_applied",
        p_reason_code: "ai_apply_ok",
        p_reason_text: "Se aplico propuesta semanal IA en templates del usuario.",
        p_payload: result || {},
        p_source: "api",
        p_model_name: this.modelName,
        p_prompt_version: this.promptVersion
      },
      token
    );

    return result;
  }

  async adjustHoy({ token, targetDate }) {
    const feed = await this.rpc.call(
      "today_feed",
      {
        p_target_date: targetDate || null
      },
      token
    );

    const enriched = normalizeFeedUiFields(feed);
    await this.rpc.call(
      "log_ai_decision_event",
      {
        p_event_name: "ai_adjustment_applied",
        p_reason_code: "hoy_ui_enriched",
        p_reason_text: "Se genero enriquecimiento UI de prioridad y recomendacion de accion en HOY.",
        p_payload: {
          items_count: enriched.length
        },
        p_source: "api",
        p_model_name: this.modelName,
        p_prompt_version: this.promptVersion
      },
      token
    );
    return enriched;
  }
}

