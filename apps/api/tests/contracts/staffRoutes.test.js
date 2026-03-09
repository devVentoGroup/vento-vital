import test from "node:test";
import assert from "node:assert/strict";
import { handleStaffRoutes } from "../../src/modules/staff/staffRoutes.js";
import { createJsonReq, createMockRes, parseBody } from "./testUtils.js";

test("staff routes dispatch presets list", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/staff/football-presets");

  const calls = [];
  const controller = {
    async listPresets() {
      calls.push("list");
    },
    async applyPreset() {
      calls.push("apply");
    },
    async getWeeklyOverview() {
      calls.push("overview");
    },
  };

  await handleStaffRoutes(req, res, url, controller);
  assert.deepEqual(calls, ["list"]);
});

test("staff routes dispatch apply preset", async () => {
  const req = createJsonReq({ method: "POST" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/staff/football-presets/apply");

  const calls = [];
  const controller = {
    async listPresets() {
      calls.push("list");
    },
    async applyPreset() {
      calls.push("apply");
    },
    async getWeeklyOverview() {
      calls.push("overview");
    },
  };

  await handleStaffRoutes(req, res, url, controller);
  assert.deepEqual(calls, ["apply"]);
});

test("staff routes return 404 on unknown path", async () => {
  const req = createJsonReq({ method: "GET" });
  const res = createMockRes();
  const url = new URL("http://localhost/api/staff/unknown");

  const controller = {
    async listPresets() {},
    async applyPreset() {},
    async getWeeklyOverview() {},
  };

  await handleStaffRoutes(req, res, url, controller);
  assert.equal(res.statusCode, 404);
  assert.equal(parseBody(res).error, "Not found");
});
