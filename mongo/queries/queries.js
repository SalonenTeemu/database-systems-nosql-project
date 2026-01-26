// UC11: User likes or reviews a game

// Check whether the user owns the game (from PostgreSQL side)
`
SELECT user_id
FROM user_games
WHERE user_id = 1
  AND game_id = 1;
`;
// If the user owns the game, insert the interaction into MongoDB

// User likes a game
db.game_interactions.insertOne({
  user_id: 1,
  game_id: 1,
  type: "like",
  created_at: new Date(),
});

// User reviews a game
db.game_interactions.insertOne({
  user_id: 1,
  game_id: 1,
  type: "review",
  content: "Great game! Really enjoyed the gameplay and graphics.",
  created_at: new Date(),
});

// UC12: View trending games

// Get top 10 trending games for the week based on likes and reviews
db.game_trending_stats.aggregate([
  {
    $match: { period_type: "week", period_key: "rolling" },
  },
  {
    $addFields: {
      totalInteractions: { $add: ["$likes", "$reviews"] },
    },
  },
  {
    $sort: { totalInteractions: -1 },
  },
  {
    $limit: 10,
  },
  {
    $project: {
      _id: 0,
      game_id: 1,
      likes: 1,
      reviews: 1,
      totalInteractions: 1,
      period_type: 1,
    },
  },
]);

// Get todays top 10 daily trending games based on likes and reviews
db.game_trending_stats.aggregate([
  {
    $match: {
      period_type: "day",
      period_key: new Date().toISOString().slice(0, 10), // like "2026-01-26"
    },
  },
  {
    $addFields: {
      totalInteractions: { $add: ["$likes", "$reviews"] },
    },
  },
  {
    $sort: { totalInteractions: -1 },
  },
  {
    $limit: 10,
  },
  {
    $project: {
      _id: 0,
      game_id: 1,
      likes: 1,
      reviews: 1,
      totalInteractions: 1,
      period_type: 1,
      period_key: 1,
    },
  },
]);

// Find game details from PostgreSQL for the trending games
`
SELECT g.game_id, g.title, g.release_date
FROM games g
WHERE g.game_id IN (X, Y, Z...); -- Game IDs from the previous MongoDB query results
`;

// Below is an example how the application might update the trending stats (day as an example period_type) using a cron job for example

// Aggregate likes and reviews for the current day
const dailyStats = db.game_interactions.aggregate([
  {
    $match: {
      created_at: {
        $gte: ISODate(new Date(new Date().setHours(0, 0, 0, 0))),
        $lt: ISODate(new Date()),
      },
    },
  },
  {
    $group: {
      _id: {
        game_id: "$game_id",
        type: "$type",
      },
      count: { $sum: 1 },
    },
  },
]);

const statsByGame = {};

// Group likes and reviews by game_id
dailyStats.forEach(({ _id, count }) => {
  const { game_id, type } = _id;

  // Initialize to 0 if not exists
  if (!statsByGame[game_id]) {
    statsByGame[game_id] = { likes: 0, reviews: 0 };
  }

  if (type === "like") statsByGame[game_id].likes = count;
  if (type === "review") statsByGame[game_id].reviews = count;
});

const periodKey = new Date().toISOString().slice(0, 10); // like "2026-01-26"

// Insert or update trending stats for each game for the day
Object.entries(statsByGame).forEach(([game_id, { likes, reviews }]) => {
  db.game_trending_stats.updateOne(
    { game_id: parseInt(game_id), period_type: "day", period_key: periodKey },
    {
      $set: {
        likes,
        reviews,
        updated_at: new Date(),
      },
    },
    { upsert: true },
  );
});

// UC13: Retrieve games with highest engagement of all-time

// Top 10 most engaged games based on interactions of all-time
db.game_interactions.aggregate([
  {
    $project: {
      game_id: 1,
      isLike: { $cond: [{ $eq: ["$type", "like"] }, 1, 0] },
      isReview: { $cond: [{ $eq: ["$type", "review"] }, 1, 0] },
      created_at: 1,
    },
  },
  {
    $group: {
      _id: "$game_id",
      likes: { $sum: "$isLike" },
      reviews: { $sum: "$isReview" },
      totalInteractions: { $sum: 1 },
      lastInteractionDate: { $max: "$created_at" },
    },
  },
  {
    $match: {
      totalInteractions: { $gte: 2 },
    },
  },
  {
    $addFields: {
      reviewToLikeRatio: {
        $cond: [{ $eq: ["$likes", 0] }, 0, { $divide: ["$reviews", "$likes"] }],
      },
      daysSinceLastInteraction: {
        $divide: [
          { $subtract: [new Date(), "$lastInteractionDate"] },
          1000 * 60 * 60 * 24,
        ],
      },
    },
  },
  {
    $addFields: {
      timeWeight: {
        $cond: [
          { $lte: ["$daysSinceLastInteraction", 1] },
          1.0,
          { $cond: [{ $lte: ["$daysSinceLastInteraction", 7] }, 0.7, 0.5] },
        ],
      },
    },
  },
  {
    $addFields: {
      totalScore: {
        $multiply: [
          "$reviewToLikeRatio",
          { $log10: { $add: ["$totalInteractions", 1] } },
          "$timeWeight",
        ],
      },
    },
  },
  {
    $sort: {
      totalScore: -1,
      reviews: -1,
    },
  },
  {
    $limit: 10, // Or any desired number of top games
  },
  {
    $project: {
      _id: 0,
      game_id: "$_id",
      likes: 1,
      reviews: 1,
      totalInteractions: 1,
      reviewToLikeRatio: { $round: ["$reviewToLikeRatio", 2] },
      interactionScore: { $round: ["$totalScore", 2] },
    },
  },
]);

// Find game details from PostgreSQL for the most engaged games
`
SELECT g.game_id, g.title, g.release_date
FROM games g
WHERE g.game_id IN (X, Y, Z...); -- Game IDs from the previous MongoDB query results
`;
