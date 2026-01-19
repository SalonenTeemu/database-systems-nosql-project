-- Enable pg_trgm extension for advanced text search capabilities
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Countries table
CREATE TABLE countries (
    country_code CHAR(3) PRIMARY KEY, -- ISO code, e.g. FIN, FRA, GER, USA etc.
    name TEXT NOT NULL,
    currency_code CHAR(3) NOT NULL -- EUR, SEK, etc.
);

-- User table to store user information
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    country_code CHAR(3) NOT NULL REFERENCES countries(country_code),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Publisher table to store game publisher information
CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    country_code CHAR(3) REFERENCES countries(country_code),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Game table to store game information
CREATE TABLE games (
    game_id SERIAL PRIMARY KEY,
    publisher_id INT NOT NULL REFERENCES publishers(publisher_id),
    title TEXT UNIQUE NOT NULL,
    description TEXT,
    release_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Genre table to store game genres
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

-- Junction table to store game prices
CREATE TABLE game_prices (
    game_id INT REFERENCES games(game_id),
    country_code CHAR(3) REFERENCES countries(country_code),
    price NUMERIC(8,2) NOT NULL CHECK (price >= 0), -- Price for this country
    PRIMARY KEY (game_id, country_code)
);

-- Junction table to associate games with genres (many-to-many relationship)
CREATE TABLE game_genres (
    game_id INT REFERENCES games(game_id),
    genre_id INT REFERENCES genres(genre_id),
    PRIMARY KEY (game_id, genre_id)
);

-- Purchase table to store data about user game purchases
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
