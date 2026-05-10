import { Router } from "express";

export function getHealth() {
  return { status: "ok" as const, uptime: process.uptime() };
}

export const healthRouter = Router();

healthRouter.get("/", (_req, res) => {
  res.json(getHealth());
});
