import express from "express";
import { usersRouter } from "./routes/users.ts";
import { ordersRouter } from "./routes/orders.ts";
import { reportsRouter } from "./routes/reports.ts";

export function createApp() {
  const app = express();
  app.use(express.json());
  app.use("/users", usersRouter);
  app.use("/orders", ordersRouter);
  app.use("/reports", reportsRouter);
  return app;
}
