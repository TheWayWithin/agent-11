import { Router, type Request, type Response } from "express";

export const reportsRouter = Router();

reportsRouter.get("/", (req: Request, res: Response) => {
  res.json({ reports: [{ id: "r1", name: "Monthly" }] });
});
