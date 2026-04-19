import { Router, type Request, type Response } from "express";

export const ordersRouter = Router();

ordersRouter.get("/", (req: Request, res: Response) => {
  const header = req.header("authorization");
  const token = header?.startsWith("Bearer ") ? header.slice("Bearer ".length) : undefined;
  const expected = process.env.API_TOKEN ?? "test-token";
  if (!token || token !== expected) {
    res.status(401).json({ error: "unauthorized" });
    return;
  }

  res.json({ orders: [{ id: 101, total: 42 }, { id: 102, total: 99 }] });
});
