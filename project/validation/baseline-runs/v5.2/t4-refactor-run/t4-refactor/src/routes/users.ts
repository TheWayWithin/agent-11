import { Router, type Request, type Response } from "express";

export const usersRouter = Router();

usersRouter.get("/", (req: Request, res: Response) => {
  res.json({ users: [{ id: 1, name: "Ada" }, { id: 2, name: "Grace" }] });
});
