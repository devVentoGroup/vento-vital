import test from "node:test";
import assert from "node:assert/strict";
import { TelemetryService } from "../../src/modules/telemetry/telemetryService.js";

test("telemetry service enforces reason fields for decision events", async () => {
  const service = new TelemetryService({
    rpcClient: {
      async call() {
        return { ok: true };
      },
    },
  });

  await assert.rejects(
    () =>
      service.trackDecision({
        token: "t",
        eventName: "hoy_recommendation_accepted",
        reasonCode: "",
        reasonText: "ok",
      }),
    (err) => {
      assert.equal(err.status, 400);
      assert.match(err.message, /reason_code is required/i);
      return true;
    }
  );
});

test("telemetry service clamps decision list limit", async () => {
  let capturedBody = null;
  const service = new TelemetryService({
    rpcClient: {
      async call(_fn, body) {
        capturedBody = body;
        return [];
      },
    },
  });

  await service.listDecisionEvents({ token: "t", limit: 9999, eventName: "x" });
  assert.equal(capturedBody.p_limit, 200);
  assert.equal(capturedBody.p_event_name, "x");
});
