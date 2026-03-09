export function createMockRes() {
  return {
    statusCode: 200,
    headers: {},
    body: "",
    writeHead(status, headers = {}) {
      this.statusCode = status;
      this.headers = headers;
    },
    end(payload = "") {
      this.body = payload;
    },
  };
}

export function createJsonReq({ method = "GET", body = null, authorization = null } = {}) {
  const chunks = body === null || body === undefined ? [] : [JSON.stringify(body)];
  const req = {
    method,
    headers: {},
    async *[Symbol.asyncIterator]() {
      for (const chunk of chunks) {
        yield chunk;
      }
    },
  };
  if (authorization) {
    req.headers.authorization = authorization;
  }
  return req;
}

export function parseBody(res) {
  try {
    return JSON.parse(res.body || "{}");
  } catch {
    return {};
  }
}
