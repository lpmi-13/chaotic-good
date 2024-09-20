import * as dotenv from 'dotenv';
import express from 'express';
import helmet from 'helmet';

import { reviewsRouter } from './reviews/reviews.router';

dotenv.config();

if (!process.env.PORT) {
    process.exit(1);
}

const PORT: number = parseInt(process.env.PORT as string, 10);
let ENVIRONMENT: String;
if (!process.env.ENVIRONMENT) {
    ENVIRONMENT = 'staging';
} else {
    ENVIRONMENT = process.env.ENVIRONMENT;
}

const app = express();

app.use(helmet());
app.use(express.json());

app.use('/api/reviews', reviewsRouter);

app.listen(PORT, () => {
    console.log(`app live in ${ENVIRONMENT}, listening on port: ${PORT}`);
});
