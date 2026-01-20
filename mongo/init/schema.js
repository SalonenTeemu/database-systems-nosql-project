db.createCollection("game_interactions");
db.createCollection("game_vectors");
db.createCollection("game_trending_stats");

db.game_interactions.insertMany([
  {
    user_id: 1,
    game_id: 1,
    type: "like",
    created_at: new Date()
  },
  {
    user_id: 2,
    game_id: 1,
    type: "review",
    content: "Great game, loved the atmosphere!",
    created_at: new Date()
  },
  {
    user_id: 3,
    game_id: 2,
    type: "like",
    created_at: new Date()
  }
]);

print("MongoDB initialization completed successfully.");
