-- Insert countries
INSERT INTO countries (country_code, name, currency_code) VALUES
('USA', 'United States', 'USD'),
('FIN', 'Finland', 'EUR'),
('SWE', 'Sweden', 'SEK'),
('GER', 'Germany', 'EUR'),
('FRA', 'France', 'EUR'),
('GBR', 'Great Britain', 'GBP'),
('JPN', 'Japan', 'JPY'),
('CAN', 'Canada', 'CAD'),
('AUS', 'Australia', 'AUD'),
('NOR', 'Norway', 'NOK');

-- Insert users
INSERT INTO users (email, username, password_hash, country_code) VALUES
('alice@email.com', 'alice', 'hash1', 'FIN'),
('bob@email.com', 'bob', 'hash2', 'USA'),
('carol@email.com', 'carol', 'hash3', 'SWE'),
('dave@email.com', 'dave', 'hash4', 'GER'),
('emma@email.com', 'emma', 'hash5', 'FRA'),
('frank@email.com', 'frank', 'hash6', 'GBR'),
('gina@email.com', 'gina', 'hash7', 'JPN'),
('henry@email.com', 'henry', 'hash8', 'CAN'),
('irene@email.com', 'irene', 'hash9', 'AUS'),
('jack@email.com', 'jack', 'hash10', 'NOR');

-- Insert publishers
INSERT INTO publishers (name, country_code) VALUES
('Nordic Games', 'FIN'),
('Pixel Forge', 'USA'),
('Dragon Works', 'JPN'),
('Blue Ocean Studios', 'SWE'),
('Ironclad Games', 'GER'),
('Sunrise Interactive', 'FRA'),
('Maple Leaf Games', 'CAN'),
('Outback Devs', 'AUS'),
('Viking Soft', 'NOR'),
('BritSoft', 'GBR');

-- Insert games
INSERT INTO games (publisher_id, title, description, release_date) VALUES
(1, 'Frozen Realms', 'Fantasy RPG set in the north', '2025-01-10'),
(2, 'Urban Racer', 'Fast-paced racing game', '2023-11-05'),
(3, 'Samurai Code', 'Stealth action in feudal Japan', '2015-02-20'),
(4, 'Ocean Depths', 'Underwater exploration game', '2023-08-15'),
(5, 'Iron Siege', 'Medieval strategy warfare', '2022-12-01'),
(6, 'Solar Drift', 'Sci-fi space racing', '2018-04-01'),
(7, 'Maple Storyline', 'Adventure RPG', '2023-09-10'),
(8, 'Desert Storm', 'Modern FPS shooter', '2023-06-22'),
(9, 'Viking Saga', 'Norse mythology RPG', '2024-03-05'),
(10,'London Heist', 'Crime action game', '2020-10-30'),
(2, 'Neon Skies', 'Cyberpunk flying shooter', '2024-05-10'),
(3, 'Ronin Path', 'Souls-like samurai RPG', '2023-11-18'),
(4, 'Deep Blue', 'Ocean survival exploration', '2024-01-22'),
(6, 'Star Nomads', 'Open-world space RPG', '2024-03-12'),
(9, 'Nordic Legends', 'Mythological adventure', '2026-01-01');

-- Insert genres
INSERT INTO genres (name) VALUES
('Action'),
('Adventure'),
('RPG'),
('Racing'),
('Strategy'),
('Simulation'),
('Shooter'),
('Indie'),
('Multiplayer'),
('Story-driven'),
('Holiday');

-- Map games to genres
INSERT INTO game_genres VALUES
(1, 3), (1, 2),
(2, 4), (2, 9),
(3, 1), (3, 3),
(4, 2), (5, 5),
(6, 4), (7, 3),
(8, 7), (9, 3),
(10, 1), (11, 1),
(12, 1), (12, 3),
(13, 2), (14, 3),
(15, 2);

-- Insert game prices for different countries
INSERT INTO game_prices VALUES
(1, 'FIN', 49.99), (1, 'USA', 59.99),
(2, 'USA', 39.99), (2, 'SWE', 399.00),
(3, 'JPN', 6200), (3, 'USA', 59.99),
(4, 'FIN', 29.99), (5, 'GER', 49.99),
(6, 'FRA', 44.99), (7, 'CAN', 39.99),
(8, 'USA', 59.99), (9, 'NOR', 499.00),
(10, 'GBR', 34.99),
(11, 'USA', 49.99), (11, 'FIN', 44.99), (11, 'GER', 49.99),
(12, 'JPN', 6500), (12, 'USA', 59.99), (12, 'GBR', 54.99),
(13, 'FRA', 39.99), (13, 'SWE', 399.00),
(14, 'USA', 69.99), (14, 'CAN', 64.99), (14, 'AUS', 74.99),
(15, 'NOR', 499.00), (15, 'FIN', 44.99), (15, 'SWE', 429.00);

-- Insert purchases
INSERT INTO purchases (user_id, country_code, total_price) VALUES
(1, 'FIN', 44.99), (1, 'FIN', 29.99), (1, 'FIN', 49.99), (1, 'FIN', 79.99),
(2, 'USA', 59.99), (2, 'USA', 49.99), (2, 'USA', 69.99),
(3, 'SWE', 399.00), (3, 'SWE', 429.00),
(4, 'GER', 49.99), (4, 'GER', 59.99),
(5, 'FRA', 44.99), (6, 'GBR', 34.99),
(7, 'JPN', 6200), (8, 'CAN', 39.99),
(9, 'AUS', 59.99), (10, 'NOR', 499.00);

-- Insert user owned games
INSERT INTO user_games VALUES
(1, 1, 1), (1, 4, 2), (1, 11, 3), (1, 15, 4),
(2, 3, 5), (2, 11, 6), (2, 14, 7),
(3, 2, 8), (3, 15, 9),
(4, 5, 10), (4, 11, 11),
(5, 6, 12),
(6, 12, 13),
(7, 3, 14),
(8, 7, 15),
(9, 14, 16),
(10, 9, 17);
