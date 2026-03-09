import { createHttpError } from "./http.js";

export class OpenAiClient {
  constructor({ apiKey, model = "gpt-4.1-mini", promptVersion = "v1" }) {
    this.apiKey = apiKey || "";
    this.model = model;
    this.promptVersion = promptVersion;
  }

  get enabled() {
    return this.apiKey.trim().length > 0;
  }

  async generateWeeklyPlanProposal({ context }) {
    if (!this.enabled) {
      throw createHttpError(503, "OpenAI API key is not configured");
    }

    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${this.apiKey}`
      },
      body: JSON.stringify({
        model: this.model,
        input: [
          {
            role: "system",
            content:
              "Eres motor de planificacion deportiva. Responde solo JSON valido. Sin recomendaciones clinicas. Respeta safety y modulo activo."
          },
          {
            role: "user",
            content: JSON.stringify({
              prompt_version: this.promptVersion,
              task: "Genera propuesta semanal modular con explicabilidad breve",
              context
            })
          }
        ],
        text: {
          format: {
            type: "json_schema",
            name: "weekly_plan_proposal",
            schema: {
              type: "object",
              additionalProperties: false,
              required: ["summary", "confidence_score", "weekly_blocks", "hoy_adjustments"],
              properties: {
                summary: { type: "string" },
                confidence_score: { type: "number", minimum: 0, maximum: 100 },
                weekly_blocks: {
                  type: "array",
                  items: {
                    type: "object",
                    additionalProperties: false,
                    required: ["module_key", "task_type", "title", "estimated_minutes", "days", "reason_text"],
                    properties: {
                      module_key: { type: "string" },
                      task_type: { type: "string" },
                      title: { type: "string" },
                      estimated_minutes: { type: "integer", minimum: 5, maximum: 180 },
                      days: { type: "array", items: { type: "integer", minimum: 1, maximum: 7 } },
                      reason_text: { type: "string" },
                      payload: { type: "object" }
                    }
                  }
                },
                hoy_adjustments: {
                  type: "array",
                  items: {
                    type: "object",
                    additionalProperties: false,
                    required: ["module_key", "reason_code", "reason_text", "recommended_action"],
                    properties: {
                      module_key: { type: "string" },
                      reason_code: { type: "string" },
                      reason_text: { type: "string" },
                      recommended_action: { type: "string" }
                    }
                  }
                }
              }
            }
          }
        }
      })
    });

    const payload = await response.json().catch(() => ({}));
    if (!response.ok) {
      throw createHttpError(response.status || 500, payload?.error?.message || "OpenAI request failed", payload);
    }

    const rawText = payload?.output_text || "";
    if (!rawText) {
      throw createHttpError(500, "OpenAI response did not contain output_text", payload);
    }

    try {
      return JSON.parse(rawText);
    } catch {
      throw createHttpError(500, "OpenAI returned invalid JSON payload", { raw_text: rawText });
    }
  }
}

