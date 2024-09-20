import express, { Request, Response } from 'express';
import * as ReviewService from './review.service';
import { BaseReview, Review } from './review.interface';

export const reviewsRouter = express.Router();

reviewsRouter.get('/', async (req: Request, res: Response) => {
    try {
        const reviews: Review[] = await ReviewService.findAll();

        res.status(200).send(reviews);
    } catch (e) {
        res.status(500).send(e).statusMessage;
    }
});

reviewsRouter.get('/:id', async (req: Request, res: Response) => {
    const id: number = parseInt(req.params.id, 10);

    try {
        const review: Review = await ReviewService.findOne(id);

        if (review) {
            return res.status(200).send(review);
        }

        res.status(400).send('item not found');
    } catch (e) {
        res.status(500).send(e).statusMessage;
    }
});

reviewsRouter.post('/', async (req: Request, res: Response) => {
    try {
        const review: BaseReview = req.body;

        const newReview = await ReviewService.create(review);

        res.status(201).json(newReview);
    } catch (e) {
        res.status(500).send(e).statusMessage;
    }
});

reviewsRouter.put('/:id', async (res: Response, req: Request) => {
    const id: number = parseInt(req.params.id, 10);

    try {
        const reviewUpdate: Review = req.body;

        const existingReview: Review = await ReviewService.findOne(id);

        if (existingReview) {
            const updatedReview = await ReviewService.update(id, reviewUpdate);
            return res.status(200).json(updatedReview);
        }
    } catch (e) {
        res.status(500).send(e).statusMessage;
    }
});

reviewsRouter.delete('/:id', async (req: Request, res: Response) => {
    try {
        const id: number = parseInt(req.params.id, 10);
        await ReviewService.remove(id);

        res.sendStatus(204);
    } catch (e) {
        res.status(500).send(e).statusMessage;
    }
});
