import test from "node:test";
import assert from "node:assert/strict";
import { PlanningController } from "../../src/modules/planning/planningController.js";
import { createJsonReq, createMockRes, parseBody } from "./testUtils.js";

test("planning controller rejects invalid week_start format", async () => {
  const req = createJsonReq({ method: "GET", authorization: "Bearer token" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/planning/weekly?week_start=03-04-2026");

  const controller = new PlanningController({
    service: {
      async getWeeklyPlan() {
        return [];
      },
    },
  });

  await controller.getWeekly(req, res, url);
  assert.equal(res.statusCode, 400);
  assert.match(parseBody(res).error, /Invalid week_start format/i);
});

test("planning controller requires bearer token", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/planning/cycle");

  const controller = new PlanningController({
    service: {
      async getCycleAdjustment() {
        return [];
      },
    },
  });

  await controller.getCycle(req, res, url);
  assert.equal(res.statusCode, 401);
  assert.equal(parseBody(res).error, "Missing bearer token");
});
