import { describe, it, expect, beforeAll } from "vitest";
import request from "supertest";
import { createApp } from "../src/app.ts";

const app = createApp();

beforeAll(() => {
  process.env.API_TOKEN = "test-token";
});

describe.each([
  ["users", { users: [{ id: 1, name: "Ada" }, { id: 2, name: "Grace" }] }],
  ["orders", { orders: [{ id: 101, total: 42 }, { id: 102, total: 99 }] }],
  ["reports", { reports: [{ id: "r1", name: "Monthly" }] }],
])("GET /%s", (path, expected) => {
  it("returns 401 without a token", async () => {
    const res = await request(app).get(`/${path}`);
    expect(res.status).toBe(401);
    expect(res.body).toEqual({ error: "unauthorized" });
  });

  it("returns 401 with a wrong token", async () => {
    const res = await request(app).get(`/${path}`).set("Authorization", "Bearer nope");
    expect(res.status).toBe(401);
  });

  it("returns 200 with the correct token", async () => {
    const res = await request(app).get(`/${path}`).set("Authorization", "Bearer test-token");
    expect(res.status).toBe(200);
    expect(res.body).toEqual(expected);
  });
});
