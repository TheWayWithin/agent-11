import express from "express";
import { itemsRouter } from "./routes/items.ts";
import { healthRouter } from "./routes/health.ts";

const app = express();
app.use(express.json());
app.use("/items", itemsRouter);
app.use("/health", healthRouter);

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => {
  console.log(`listening on :${port}`);
});
