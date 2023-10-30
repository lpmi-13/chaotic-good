interface ReviewInterface {
  reviewText: string;
}
export const Review = ({ reviewText }: ReviewInterface) => {
  return <div className="review">{reviewText}</div>;
};
