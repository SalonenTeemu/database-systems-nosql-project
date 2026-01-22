-- UC1: User registration
INSERT INTO users (email, username, password_hash, country_code)
VALUES ('john@email.com', 'john', 'hash11', 'USA');

-- UC2: User login / account lookup 
SELECT user_id, email, username, password_hash, country_code
FROM users
WHERE email = 'john@email.com';

-- UC3: Browse available games
-- 1) Logged in user
SELECT 
    g.game_id,
    g.title,
    gp.price,
    c.currency_code,
    p.name AS publisher,
    ARRAY_AGG(gen.name ORDER BY gen.name) AS genres
FROM games g
JOIN game_prices gp ON g.game_id = gp.game_id
JOIN countries c ON gp.country_code = c.country_code
JOIN publishers p ON g.publisher_id = p.publisher_id
JOIN game_genres gg ON g.game_id = gg.game_id
JOIN genres gen ON gg.genre_id = gen.genre_id
WHERE gp.country_code = (
    SELECT country_code
    FROM users
    WHERE user_id = 1 -- Id of requesting user
)
GROUP BY
    g.game_id,
    g.title,
    gp.price,
    c.currency_code,
    p.name
ORDER BY g.release_date DESC;

-- 2) Non-logged in user (use country code as parameter)
SELECT 
    g.game_id,
    g.title,
    gp.price,
    c.currency_code,
    p.name AS publisher,
    ARRAY_AGG(gen.name ORDER BY gen.name) AS genres
FROM games g
JOIN game_prices gp ON g.game_id = gp.game_id
JOIN countries c ON gp.country_code = c.country_code
JOIN publishers p ON g.publisher_id = p.publisher_id
JOIN game_genres gg ON g.game_id = gg.game_id
JOIN genres gen ON gg.genre_id = gen.genre_id
WHERE gp.country_code = :'country_code' -- Country code parameter
  AND gen.name IN ('Action', 'Adventure', 'RPG') -- Could also be parameterized
  AND gp.price <= 60.00 -- Could also be parameterized
  AND g.release_date >= '2024-01-01' -- Could also be parameterized
GROUP BY
    g.game_id,
    g.title,
    gp.price,
    c.currency_code,
    p.name
ORDER BY g.release_date DESC;

-- UC4: Search games, similar for title, publisher or description similar to a search term
WITH search_suggestions AS (
    SELECT
       g.game_id,
       g.title,
       g.description,
       gp.price,
       c.currency_code,
       p.name AS publisher
    FROM games g
    JOIN game_prices gp ON g.game_id = gp.game_id
    JOIN countries c ON gp.country_code = c.country_code
    JOIN publishers p ON g.publisher_id = p.publisher_id
    WHERE 
    (   g.title % :'search_term' -- Title term parameter (default 0.3 threshold)
        OR p.name % :'search_term' -- For publisher search
        OR g.description % :'search_term' -- For description search
    )
    AND gp.country_code = (
        SELECT country_code
        FROM users
        WHERE user_id = 1 -- Id of requesting user
    )
    LIMIT 500
)
SELECT
    game_id,
    title,
    price,
    currency_code,
    publisher,
    (
        similarity(title, :'search_term') * 1.00 +
        similarity(publisher, :'search_term') * 0.60 +
        similarity(description, :'search_term') * 0.30 +
        (1.0 - LEAST(levenshtein(lower(title), lower(:'search_term')), 10) / 10.0) * 0.40
    ) AS score
FROM search_suggestions
ORDER BY score DESC
LIMIT 25;

-- UC5: View game details 
SELECT 
    g.title,
    g.description,
    g.release_date,
    p.name AS publisher,
    gp.price,
    c.currency_code,
    g.hardware_requirements
FROM games g
JOIN publishers p ON g.publisher_id = p.publisher_id
JOIN game_prices gp ON g.game_id = gp.game_id
JOIN countries c ON gp.country_code = c.country_code
WHERE g.game_id = 1
AND gp.country_code = (
    SELECT country_code
    FROM users
    WHERE user_id = 1 -- Id of requesting user
);

-- UC6: Publisher adds a new game
BEGIN;

WITH new_game AS (
    INSERT INTO games (publisher_id, title, description, release_date, hardware_requirements)
    VALUES (1, 'Santas Workshop', 'A festive holiday-themed game', '2025-09-15', '{"minimum": {"os": "Windows 64-bit", "cpu": "i3", "ram": "8GB", "gpu": "GTX 750", "storage": "15GB"}, "recommended": {"os": "Windows 10 or later 64-bit", "cpu": "i5", "ram": "16GB", "gpu": "GTX 1060", "storage": "20GB"}}'::JSONB)
    RETURNING game_id
),
-- Insert prices for the new game (example for USA and Finland)
insert_prices AS (
    INSERT INTO game_prices (game_id, country_code, price)
    VALUES
    ((SELECT game_id FROM new_game), 'USA', 59.99),
    ((SELECT game_id FROM new_game), 'FIN', 49.99)
),
-- Insert genre for the new game
insert_genres AS (
    INSERT INTO game_genres (game_id, genre_id)
    SELECT game_id, 11 -- Holiday genre_id
    FROM new_game
)
SELECT * FROM new_game;

COMMIT;

-- UC7: Publisher updates game
BEGIN;

-- Update the game description and hardware requirements for recommended storage
UPDATE games
SET description = 'Fantasy RPG set in the north. NOW WITH MORE MAGIC!', hardware_requirements = jsonb_set(hardware_requirements, '{recommended,storage}', '"35GB"')
WHERE game_id = 1; -- Frozen Realms game_id

-- Update the price for Finland
UPDATE game_prices
SET price = 29.99
WHERE game_id = 1 AND country_code = 'FIN';

COMMIT;

-- UC8: Purchase a game
BEGIN;
    WITH new_purchase AS (
        INSERT INTO purchases (user_id, country_code, total_price)
        VALUES (1, 'FIN', 49.99)
        RETURNING purchase_id
    )
    INSERT INTO user_games (game_id, user_id, purchase_id)
    VALUES (16, 1, (SELECT purchase_id FROM new_purchase)); -- Santas Workshop game_id
COMMIT;

-- UC9: View owned games
SELECT g.game_id, g.title, g.description
FROM user_games ug
JOIN games g ON ug.game_id = g.game_id
WHERE ug.user_id = 1;

-- UC10: View purchase history
SELECT p.purchase_id, p.purchase_time, p.total_price, c.currency_code, g.title
FROM purchases p
JOIN countries c ON p.country_code = c.country_code
JOIN user_games ug ON p.purchase_id = ug.purchase_id
JOIN games g ON ug.game_id = g.game_id
WHERE p.user_id = 1
ORDER BY p.purchase_time DESC;