import { BaseReview, Review } from './review.interface';
import { Reviews } from './reviews.interface';

// we'll move this data to postgres once things are wired up
const reviews: Reviews = {
    1: {
        id: 1,
        reviewer: 'Alice',
        rating: 4,
        comment: 'This this was great!',
    },
    2: {
        id: 2,
        reviewer: 'Bob',
        rating: 2,
        comment: 'This things was not very good',
    },
    3: {
        id: 3,
        reviewer: 'Carla',
        rating: 3,
        comment: 'This thing was adequate',
    },
};

export const findAll = async (): Promise<Review[]> => Object.values(reviews);

export const findOne = async (id: number): Promise<Review> => reviews[id];

export const create = async (newReview: BaseReview): Promise<Review> => {
    const id = new Date().valueOf();

    reviews[id] = {
        id,
        ...newReview,
    };

    return reviews[id];
};

export const update = async (
    id: number,
    reviewUpdate: BaseReview
): Promise<Review | null> => {
    const review = await findOne(id);

    if (!review) {
        return null;
    }

    reviews[id] = { id, ...reviewUpdate };

    return reviews[id];
};

export const remove = async (id: number): Promise<null | void> => {
    const review = await findOne(id);

    if (!review) {
        return null;
    }

    delete reviews[id];
};
