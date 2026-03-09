import { normalizeHoyTask } from "@vento-vital/contracts";

const MODULE_LABELS = {
  training: "Entrenamiento",
  nutrition: "Nutrición",
  habits: "Hábitos",
  recovery: "Recuperación"
};

const TASK_TYPE_LABELS = {
  workout: "sesión",
  nutrition: "nutrición",
  metrics: "métrica",
  sleep: "sueño",
  recovery: "recuperación",
  reminder: "recordatorio"
};

export function presentHoyTasks(rawTasks) {
  return rawTasks.map((raw) => {
    const t = normalizeHoyTask(raw);
    const dateLabel = t.taskDate || "sin fecha";
    const moduleKey = raw.module_key || "training";
    const moduleLabel = MODULE_LABELS[moduleKey] || moduleKey;
    const score = typeof raw.priority_score === "number" ? raw.priority_score : t.priority;
    const reasonText = raw.reason_text || "Prioridad base del plan.";
    const safetyState = raw.safety_state || "ok";
    const taskTypeLabel = TASK_TYPE_LABELS[t.taskType] || t.taskType;
    return {
      id: t.id,
      title: t.title,
      status: t.status,
      taskDate: t.taskDate,
      taskType: t.taskType,
      moduleKey,
      priorityScore: score,
      reasonCode: raw.reason_code || "base_priority",
      reasonText,
      safetyState,
      meta: `${moduleLabel} · ${taskTypeLabel} · ${dateLabel}`
    };
  });
}
