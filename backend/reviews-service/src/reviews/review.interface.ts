export interface BaseReview {
    reviewer: string;
    rating: number;
    comment: string;
}

export interface Review extends BaseReview {
    id: number;
}
