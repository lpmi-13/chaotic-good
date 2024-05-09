import * as dotenv from 'dotenv';
import express from 'express';
import helmet from 'helmet';

import { reviewsRouter } from './reviews/reviews.router';

dotenv.config();

if (!process.env.PORT) {
    process.exit(1);
}

const PORT: number = parseInt(process.env.PORT as string, 10);

const app = express();

app.use(helmet());
app.use(express.json());

app.use('/api/reviews', reviewsRouter);

app.listen(PORT, () => {
    console.log(
        `app live in ${process.env.ENVIRONMENT}, listening on port: ${PORT}`
    );
});
