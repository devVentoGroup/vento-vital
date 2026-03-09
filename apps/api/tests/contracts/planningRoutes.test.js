import test from "node:test";
import assert from "node:assert/strict";
import { handlePlanningRoutes } from "../../src/modules/planning/planningRoutes.js";
import { createJsonReq, createMockRes, parseBody } from "./testUtils.js";

test("planning routes dispatch weekly endpoint", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/planning/weekly?week_start=2026-03-02");

  const calls = [];
  const controller = {
    async getWeekly() {
      calls.push("weekly");
    },
    async getCycle() {
      calls.push("cycle");
    },
  };

  await handlePlanningRoutes(req, res, url, controller);
  assert.deepEqual(calls, ["weekly"]);
});

test("planning routes dispatch cycle endpoint", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/planning/cycle?date=2026-03-04");

  const calls = [];
  const controller = {
    async getWeekly() {
      calls.push("weekly");
    },
    async getCycle() {
      calls.push("cycle");
    },
  };

  await handlePlanningRoutes(req, res, url, controller);
  assert.deepEqual(calls, ["cycle"]);
});

test("planning routes return 404 on unknown path", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/planning/unknown");

  const controller = {
    async getWeekly() {},
    async getCycle() {},
  };

  await handlePlanningRoutes(req, res, url, controller);
  assert.equal(res.statusCode, 404);
  assert.equal(parseBody(res).error, "Not found");
});
