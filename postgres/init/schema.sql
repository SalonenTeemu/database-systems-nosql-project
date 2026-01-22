-- Enable pg_trgm extension and fuzzystrmatch for advanced text search capabilities
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch";

-- Set similarity lower threshold for pg_trgm searches for increased search results
SET pg_trgm.similarity_threshold = 0.2;

-- Tables --

-- Countries table to store country and currency information
CREATE TABLE countries (
    country_code CHAR(3) PRIMARY KEY, -- ISO code, e.g. FIN, FRA, GER, USA etc.
    name TEXT NOT NULL,
    currency_code CHAR(3) NOT NULL -- EUR, SEK, etc.
);

-- Users table to store user information
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    country_code CHAR(3) NOT NULL REFERENCES countries(country_code),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Publishers table to store game publisher information
CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    country_code CHAR(3) REFERENCES countries(country_code),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Games table to store game information
CREATE TABLE games (
    game_id SERIAL PRIMARY KEY,
    publisher_id INT NOT NULL REFERENCES publishers(publisher_id),
    title TEXT UNIQUE NOT NULL,
    description TEXT,
    release_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hardware_requirements JSONB
);

-- Genres table to store game genres
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

-- Junction table to associate games with genres
CREATE TABLE game_genres (
    game_id INT REFERENCES games(game_id),
    genre_id INT REFERENCES genres(genre_id),
    PRIMARY KEY (game_id, genre_id)
);

-- Junction table to store game prices per country (also determines availability if there is a row for the country)
CREATE TABLE game_prices (
    game_id INT REFERENCES games(game_id),
    country_code CHAR(3) REFERENCES countries(country_code),
    price NUMERIC(8,2) NOT NULL CHECK (price >= 0), -- Price for this country
    PRIMARY KEY (game_id, country_code)
);

-- Purchases table to store data about user game purchases
CREATE TABLE purchases (
    purchase_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    country_code CHAR(3) NOT NULL REFERENCES countries(country_code),
    total_price NUMERIC(8,2) NOT NULL CHECK (total_price >= 0),
    purchase_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Junction table to associate users with their purchased games
CREATE TABLE user_games (
    user_id INT REFERENCES users(user_id),
    game_id INT REFERENCES games(game_id),
    purchase_id INT REFERENCES purchases(purchase_id),
    PRIMARY KEY (user_id, game_id, purchase_id)
);

-- Indexes --

-- Countries table and users table don't require manually created indexes as primary and unique keys have indexes by default, and they are sufficient

-- Publishers table
CREATE INDEX idx_publishers_name_trgm ON publishers USING gin (name gin_trgm_ops);

-- Games table
CREATE INDEX idx_games_title_trgm ON games USING gin (title gin_trgm_ops);
CREATE INDEX idx_games_description_trgm ON games USING gin (description gin_trgm_ops);
CREATE INDEX idx_games_publisher_id ON games(publisher_id);
CREATE INDEX idx_games_release_date ON games(release_date);

-- Game genres junction table
CREATE INDEX idx_game_genres_genre_id ON game_genres(genre_id);
CREATE INDEX idx_game_genres_genre_id_game_id ON game_genres(genre_id, game_id);

-- Game prices table
CREATE INDEX idx_game_prices_country ON game_prices(country_code);
CREATE INDEX idx_game_prices_country_price ON game_prices(country_code, price);

-- Purchases table
CREATE INDEX idx_purchases_user_time ON purchases(user_id, purchase_time DESC);

-- User games junction table
CREATE INDEX idx_user_games_purchase_id ON user_games(purchase_id);