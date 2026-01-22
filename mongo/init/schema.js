// Create collection for game interactions (likes, reviews)
db.createCollection("game_interactions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["game_id", "user_id", "type", "created_at"],
      properties: {
        game_id: {
          bsonType: "int",
          description: "Must be a valid game ID",
        },
        user_id: {
          bsonType: "int",
          description: "Must be a valid user ID",
        },
        type: {
          enum: ["like", "review"],
          description: "Interaction type",
        },
        content: {
          bsonType: "string",
          description: "Optional review text",
        },
        created_at: {
          bsonType: "date",
        },
      },
    },
  },
  validationLevel: "strict",
  validationAction: "error",
});

// Create collection for game vector embeddings
db.createCollection("game_vectors", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["game_id", "embedding"],
      properties: {
        game_id: {
          bsonType: "int",
        },
        embedding: {
          bsonType: "array",
          items: {
            bsonType: "double",
          },
          description: "Vector embedding for similarity search",
        },
      },
    },
  },
  validationLevel: "strict",
  validationAction: "error",
});

// Create collection for aggregated trending game statistics
db.createCollection("game_trending_stats", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "game_id",
        "period_type",
        "period_key",
        "likes",
        "reviews",
        "updated_at",
      ],
      properties: {
        game_id: {
          bsonType: "int",
          description: "ID of the game",
        },

        period_type: {
          enum: ["day", "week", "month", "year"],
          description: "Aggregation level",
        },

        period_key: {
          bsonType: "string",
          description: "Identifies the period (YYYY-MM-DD or 'rolling')",
        },

        likes: {
          bsonType: "int",
          minimum: 0,
          description: "Total likes for the period",
        },

        reviews: {
          bsonType: "int",
          minimum: 0,
          description: "Total reviews for the period",
        },

        updated_at: {
          bsonType: "date",
          description: "Last update timestamp",
        },
      },
    },
  },
  validationLevel: "strict",
  validationAction: "error",
});

print("MongoDB initialization completed successfully.");
