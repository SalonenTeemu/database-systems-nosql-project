-- UC1: User registration
INSERT INTO users (email, username, password_hash, country_code)
VALUES ('john@example.com', 'john_doe', 'hashed_password_123', 'USA');

-- UC2: User login / account lookup 
SELECT user_id, email, username, password_hash, country_code
FROM users
WHERE email = 'alice@example.com';

-- UC3: Browse available games
-- Logged in user
SELECT 
    g.game_id,
    g.title,
    gp.price,
    c.currency_code,
    p.name AS publisher
FROM games g
JOIN game_prices gp ON g.game_id = gp.game_id
JOIN countries c ON gp.country_code = c.country_code
JOIN publishers p ON g.publisher_id = p.publisher_id
WHERE gp.country_code = (
    SELECT country_code
    FROM users
    WHERE user_id = 1 -- Id of requesting user
)
ORDER BY g.release_date DESC;

-- Non-logged in user (use country code as parameter)
SELECT 
    g.game_id,
    g.title,
    gp.price,
    c.currency_code,
    p.name AS publisher
FROM games g
JOIN game_prices gp ON g.game_id = gp.game_id
JOIN countries c ON gp.country_code = c.country_code
JOIN publishers p ON g.publisher_id = p.publisher_id
WHERE gp.country_code = $1 -- Country code parameter
AND g.game_id IN (
    SELECT gg.game_id
    FROM game_genres gg
    JOIN genres gen ON gg.genre_id = gen.genre_id
    WHERE gen.name = 'Action'
)
AND gp.price = 0
AND g.release_date >= '2026-01-01'
ORDER BY g.release_date DESC;

-- UC4: Search games, similar for title, publisher or description
SELECT similarity(g.title, $1) AS title_score,
       g.game_id,
       g.title,
       gp.price,
       c.currency_code,
       p.name AS publisher
FROM games g
JOIN game_prices gp ON g.game_id = gp.game_id
JOIN countries c ON gp.country_code = c.country_code
JOIN publishers p ON g.publisher_id = p.publisher_id
WHERE g.title % $1 -- Search term parameter
AND gp.country_code = (
    SELECT country_code
    FROM users
    WHERE user_id = 1 -- Id of requesting user
)
AND p.name 
ORDER BY title_score DESC
LIMIT 25;

-- UC5: View game details 
SELECT 
    g.title,
    g.description,
    g.release_date,
    p.name AS publisher,
    gp.price,
    c.currency_code
FROM games g
JOIN publishers p ON g.publisher_id = p.publisher_id
JOIN game_prices gp ON g.game_id = gp.game_id
JOIN countries c ON gp.country_code = c.country_code
WHERE g.game_id = 5 
AND gp.country_code = (
    SELECT country_code
    FROM users
    WHERE user_id = 1 -- Id of requesting user
);

-- UC6: Publisher adds a new game
BEGIN;
    WITH new_game AS (
        INSERT INTO games (publisher_id, title, description, release_date)
        VALUES (1, 'New Exciting Game', 'An exciting new game description.', '2024-09-15')
        RETURNING game_id
    )
    INSERT INTO game_prices (game_id, country_code, price)
    SELECT game_id, 'USA', 59.99
    FROM new_game;
COMMIT;

-- UC7: Publisher updates game
UPDATE games
SET description = 'Updated game description.'
WHERE game_id = 10

UPDATE game_prices
SET price = 29.99
WHERE game_id = 10 AND country_code = 'FIN';

-- UC8: Purchase a game
BEGIN;
    WITH new_purchase AS (
        INSERT INTO purchases (user_id, country_code, total_price)
        VALUES (1, 'FIN', 59.99);
        RETURNING purchase_id
    )
    INSERT INTO user_games (game_id, user_id, purchase_id)
    VALUES (1, 1, (SELECT purchase_id FROM new_purchase));
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