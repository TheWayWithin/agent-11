import { describe, it, expect } from "vitest";
import { paginate } from "../src/utils/paginate.ts";

describe("paginate", () => {
  const items = Array.from({ length: 25 }, (_, i) => i + 1);

  it("returns the first page with correct slice", () => {
    const r = paginate(items, 1, 10);
    expect(r.items).toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    expect(r.page).toBe(1);
    expect(r.pageSize).toBe(10);
    expect(r.totalItems).toBe(25);
    expect(r.totalPages).toBe(3);
  });

  it("returns a middle page with correct slice", () => {
    const r = paginate(items, 2, 10);
    expect(r.items).toEqual([11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
  });

  it("returns the final partial page", () => {
    const r = paginate(items, 3, 10);
    expect(r.items).toEqual([21, 22, 23, 24, 25]);
  });

  it("clamps page < 1 to page 1", () => {
    const r = paginate(items, 0, 10);
    expect(r.page).toBe(1);
    expect(r.items[0]).toBe(1);
  });
});
