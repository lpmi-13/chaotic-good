import express, { Request, Response } from 'express';
import { Review } from './review.interface';
import sql from '../db';

export const reviewsRouter = express.Router();

reviewsRouter.get('/', async (req: Request, res: Response) => {
    try {
        const reviews = await sql`SELECT * FROM reviews`;
        if (reviews.length === 0) {
            return res.status(400).json({ message: 'no reviews found' });
        }

        return res.json(reviews);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching reviews', error });
    }
});

reviewsRouter.get('/:id', async (req: Request, res: Response) => {
    const id: number = parseInt(req.params.id, 10);
    try {
        const review = await sql`SELECT * FROM reviews WHERE id = ${id}`;
        if (review.length === 0) {
            return res.status(404).json({ message: 'review not found' });
        }
        res.json(review[0]);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching review', error });
    }
});

reviewsRouter.post('/', async (req: Request, res: Response) => {
    const review: Review = req.body;

    console.log({ review });

    try {
        const postedReview = await sql`
      INSERT INTO reviews (reviewer, rating, comment)
      VALUES (${review.reviewer}, ${review.rating}, ${review.comment})
      RETURNING *
    `;
        res.status(201).json(postedReview[0]);
    } catch (error) {
        res.status(500).json({ message: 'Error creating review', error });
    }
});

reviewsRouter.put('/:id', async (res: Response, req: Request) => {
    const id: number = parseInt(req.params.id, 10);
    const { reviewer, rating, comment } = req.body;

    try {
        const result = await sql`
      UPDATE reviews
      SET reviewer = ${reviewer}, rating = ${rating}, comment = ${comment}
      WHERE id = ${id}
      RETURNING *
    `;
        if (result.length === 0) {
            return res.status(404).json({ message: 'Review not found' });
        }
        res.json(result[0]);
    } catch (error) {
        res.status(500).json({ message: 'Error updating review', error });
    }
});

reviewsRouter.delete('/:id', async (req: Request, res: Response) => {
    const id: number = parseInt(req.params.id, 10);

    try {
        const result =
            await sql`DELETE FROM reviews WHERE id = ${id} RETURNING *`;
        if (result.length === 0) {
            return res.status(404).json({ message: 'Review not found' });
        }
        res.status(204).send(); // No content after successful deletion
    } catch (error) {
        res.status(500).json({ message: 'Error deleting review', error });
    }
});
