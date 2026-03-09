export function createHttpError(status, message, details = null) {
  const error = new Error(message);
  error.status = status;
  if (details !== null) {
    error.details = details;
  }
  return error;
}

export async function readJsonBody(req) {
  let raw = "";
  for await (const chunk of req) raw += chunk;
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch {
    throw createHttpError(400, "Invalid JSON body");
  }
}

export function sendJson(res, status, data) {
  res.writeHead(status, { "content-type": "application/json; charset=utf-8" });
  res.end(JSON.stringify(data));
}

export function notFound(res) {
  sendJson(res, 404, { error: "Not found" });
}
