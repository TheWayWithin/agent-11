import { Router, type Request, type Response } from "express";

export const ordersRouter = Router();

ordersRouter.get("/", (req: Request, res: Response) => {
  res.json({ orders: [{ id: 101, total: 42 }, { id: 102, total: 99 }] });
});
