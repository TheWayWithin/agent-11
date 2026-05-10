import express from "express";
import { requireAuth } from "./middleware/auth.ts";
import { usersRouter } from "./routes/users.ts";
import { ordersRouter } from "./routes/orders.ts";
import { reportsRouter } from "./routes/reports.ts";

export function createApp() {
  const app = express();
  app.use(express.json());
  app.use("/users", requireAuth, usersRouter);
  app.use("/orders", requireAuth, ordersRouter);
  app.use("/reports", requireAuth, reportsRouter);
  return app;
}
