import { describe, it, expect } from "vitest";
import { getHealth } from "../src/routes/health.ts";

describe("getHealth", () => {
  it("returns status ok", () => {
    const r = getHealth();
    expect(r.status).toBe("ok");
  });

  it("returns a non-negative numeric uptime", () => {
    const r = getHealth();
    expect(typeof r.uptime).toBe("number");
    expect(r.uptime).toBeGreaterThanOrEqual(0);
  });
});
