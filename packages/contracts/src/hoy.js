export function normalizeHoyTask(raw) {
  return {
    id: raw.id,
    title: raw.title || "Task",
    taskType: raw.task_type || "workout",
    status: raw.status || "pending",
    taskDate: raw.task_date || null,
    priority: typeof raw.priority === "number" ? raw.priority : 50
  };
}

export function toWearTask(raw) {
  const t = normalizeHoyTask(raw);
  return {
    id: t.id,
    ttl: t.title,
    ty: t.taskType,
    st: t.status
  };
}

export function toWearHoySnapshot(tasks) {
  return {
    generatedAt: new Date().toISOString(),
    count: tasks.length,
    tasks: tasks.map(toWearTask)
  };
}
