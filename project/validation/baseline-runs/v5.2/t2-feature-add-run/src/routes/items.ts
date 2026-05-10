import { Router } from "express";
import { paginate } from "../utils/paginate.ts";

const DATA = Array.from({ length: 47 }, (_, i) => ({
  id: i + 1,
  name: `Item ${i + 1}`,
}));

export const itemsRouter = Router();

itemsRouter.get("/", (req, res) => {
  const page = Number(req.query.page ?? 1);
  const pageSize = Number(req.query.pageSize ?? 10);
  res.json(paginate(DATA, page, pageSize));
});
