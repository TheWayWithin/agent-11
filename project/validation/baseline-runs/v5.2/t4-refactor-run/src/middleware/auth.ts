import type { Request, Response, NextFunction } from "express";

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.header("authorization");
  const token = header?.startsWith("Bearer ") ? header.slice("Bearer ".length) : undefined;
  const expected = process.env.API_TOKEN ?? "test-token";
  if (!token || token !== expected) {
    res.status(401).json({ error: "unauthorized" });
    return;
  }
  next();
}
