import { Review } from "./components/Review";
import { ReviewButton } from "./components/CreateReviewButton";
import { LoginButton } from "./components/LoginButton";
import "./App.css";

const SAMPLE_REVIEWS = [
    "This is great!",
    "Not so much",
    "I can haz cheezburger",
    "also this",
];

function App() {
    return (
        <div className="App">
            <header className="App-header">
                <div>Welcome to Reviews Site!</div>
                <LoginButton></LoginButton>
            </header>
            <main>
                <div className="review-container">
                    {SAMPLE_REVIEWS.map((review) => (
                        <Review key={review} reviewText={review} />
                    ))}
                </div>
            </main>
            <ReviewButton />
        </div>
    );
}

export default App;
