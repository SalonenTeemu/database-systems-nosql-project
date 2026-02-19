const startDate = new Date();
startDate.setDate(startDate.getDate() - 14); // Start date 14 days ago
const numDays = 14; // Insert data for 14 days
const games = Array.from({ length: 15 }, (_, i) => i + 1); // game_id 1-15
const users = Array.from({ length: 9 }, (_, i) => i + 2); // user_id 2-10 (user_id 1 is reserved for query examples)

const interactions = [];

const now = new Date(); // current time

// Generate game interactions per day
for (let d = 0; d <= numDays; d++) {
  const day = new Date(startDate);
  day.setDate(day.getDate() + d);

  const startOfDay = new Date(day);
  startOfDay.setHours(0, 0, 0, 0);

  // Use endOfDay = current time if this is today, otherwise end of day
  const endOfDay = new Date(day);
  if (
    day.getFullYear() === now.getFullYear() &&
    day.getMonth() === now.getMonth() &&
    day.getDate() === now.getDate()
  ) {
    endOfDay.setTime(now.getTime()); // cap to current time
  } else {
    endOfDay.setHours(23, 59, 59, 999); // regular end of day
  }

  games.forEach((game_id) => {
    users.forEach((user_id) => {
      // Overall about ~20% chance user likes
      if (Math.random() < 0.04) {
        // Check if like already exists
        const likeExists = interactions.some(
          (i) =>
            i.user_id === user_id && i.game_id === game_id && i.type === "like",
        );
        // Only add like if it doesn't already exist
        if (!likeExists) {
          interactions.push({
            user_id,
            game_id,
            type: "like",
            created_at: new Date(
              startOfDay.getTime() +
                Math.random() * (endOfDay.getTime() - startOfDay.getTime()),
            ),
          });
        }
      }
      // Overall about ~15% chance user reviews
      if (Math.random() < 0.03) {
        // Check if review already exists
        const reviewExists = interactions.some(
          (i) =>
            i.user_id === user_id &&
            i.game_id === game_id &&
            i.type === "review",
        );
        // Only add review if it doesn't already exist
        if (!reviewExists) {
          interactions.push({
            user_id,
            game_id,
            type: "review",
            content: "Review for game " + game_id,
            created_at: new Date(
              startOfDay.getTime() +
                Math.random() * (endOfDay.getTime() - startOfDay.getTime()),
            ),
          });
        }
      }
    });
  });
}

// Insert interactions to the collection
db.game_interactions.insertMany(interactions);

// Aggregate daily stats from interactions
const dailyStats = [];
for (let d = 0; d <= numDays; d++) {
  const day = new Date(startDate);
  day.setDate(day.getDate() + d);
  const isoDate = day.toISOString().slice(0, 10);

  games.forEach((game_id) => {
    const likes = interactions.filter(
      (i) =>
        i.game_id === game_id &&
        i.type === "like" &&
        i.created_at.toISOString().slice(0, 10) === isoDate,
    ).length;
    const reviews = interactions.filter(
      (i) =>
        i.game_id === game_id &&
        i.type === "review" &&
        i.created_at.toISOString().slice(0, 10) === isoDate,
    ).length;

    dailyStats.push({
      game_id,
      period_type: "day",
      period_key: isoDate,
      likes,
      reviews,
      updated_at: new Date(
        day.getTime() + 23 * 60 * 60 * 1000 + 59 * 60 * 1000 + 59 * 1000,
      ),
    });
  });
}
// Insert daily trending stats to the collection
db.game_trending_stats.insertMany(dailyStats);

// Compute weekly rolling trending stats
games.forEach((game_id) => {
  const weekLikes = dailyStats
    .filter((ds) => ds.game_id === game_id)
    .reduce((sum, ds) => sum + ds.likes, 0);
  const weekReviews = dailyStats
    .filter((ds) => ds.game_id === game_id)
    .reduce((sum, ds) => sum + ds.reviews, 0);

  // Insert weekly rolling stats to the collection
  db.game_trending_stats.insertOne({
    game_id,
    period_type: "week",
    period_key: "rolling",
    likes: weekLikes,
    reviews: weekReviews,
    updated_at: new Date(),
  });
});

// Compute monthly rolling trending stats
games.forEach((game_id) => {
  const monthLikes = dailyStats
    .filter((ds) => ds.game_id === game_id)
    .reduce((sum, ds) => sum + ds.likes, 0);
  const monthReviews = dailyStats
    .filter((ds) => ds.game_id === game_id)
    .reduce((sum, ds) => sum + ds.reviews, 0);

  // Insert monthly rolling stats to the collection
  db.game_trending_stats.insertOne({
    game_id,
    period_type: "month",
    period_key: "rolling",
    likes: monthLikes,
    reviews: monthReviews,
    updated_at: new Date(),
  });
});

print("MongoDB seed data inserted successfully.");
