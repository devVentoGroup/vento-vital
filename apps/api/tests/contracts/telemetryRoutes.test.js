import test from "node:test";
import assert from "node:assert/strict";
import { handleTelemetryRoutes } from "../../src/modules/telemetry/telemetryRoutes.js";
import { createJsonReq, createMockRes, parseBody } from "./testUtils.js";

test("telemetry routes dispatch decision endpoint", async () => {
  const req = createJsonReq({ method: "POST" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/telemetry/decision");

  const calls = [];
  const controller = {
    async track() {
      calls.push("track");
    },
    async trackDecision() {
      calls.push("decision");
    },
    async listDecisions() {
      calls.push("list");
    },
  };

  await handleTelemetryRoutes(req, res, url, controller);
  assert.deepEqual(calls, ["decision"]);
});

test("telemetry routes dispatch decisions list endpoint", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/telemetry/decisions?limit=20");

  const calls = [];
  const controller = {
    async track() {
      calls.push("track");
    },
    async trackDecision() {
      calls.push("decision");
    },
    async listDecisions() {
      calls.push("list");
    },
  };

  await handleTelemetryRoutes(req, res, url, controller);
  assert.deepEqual(calls, ["list"]);
});

test("telemetry routes return 404 on unknown path", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/telemetry/unknown");

  const controller = {
    async track() {},
    async trackDecision() {},
    async listDecisions() {},
  };

  await handleTelemetryRoutes(req, res, url, controller);
  assert.equal(res.statusCode, 404);
  assert.equal(parseBody(res).error, "Not found");
});
