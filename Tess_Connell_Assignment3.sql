-- Database for Great Walks of New Zealand
-- Purpose: to explore and select a walk best suited for travel plans
CREATE DATABASE Great_Walks_NZ;

USE Great_Walks_NZ;

-- Create table for Great Walk regions
CREATE TABLE Region
	(Region_ID INTEGER PRIMARY KEY,
    Region VARCHAR(50) NOT NULL UNIQUE,
    North_or_South VARCHAR(10)
    );

-- Create table for Great Walk details
CREATE TABLE Walk_details 
	(Walk_ID INTEGER PRIMARY KEY,
	Walk_name VARCHAR(50) NOT NULL,
    Distance FLOAT NOT NULL,
	Min_days INTEGER,
	Max_days INTEGER,
	Grade VARCHAR(50),
	Circuit_or_oneway VARCHAR(50),
    Closest_town VARCHAR(50),
    Distance_from_town_mins INTEGER,
	Region_ID INTEGER, 
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID)
	);

-- Create table for Great Walk hut prices
CREATE TABLE Hut_prices
	(Walk_ID INTEGER,
    Summer_hut_prices FLOAT,
    Winter_hut_prices FLOAT,
    Shoulder_hut_prices FLOAT,
    FOREIGN KEY (Walk_ID) REFERENCES Walk_details(Walk_ID)
    );

-- Create table for Great Walk camping prices
CREATE TABLE Campsite_prices
	(Walk_ID INTEGER,
    Summer_tent_prices FLOAT,
    Non_summer_tent_prices FLOAT,
    FOREIGN KEY (Walk_ID) REFERENCES Walk_details(Walk_ID)
    );

-- Populate all tables with data
INSERT INTO Region
    (Region_ID, Region, North_or_South)
    VALUES
    ('1', 'Hawkes Bay', 'North'),
    ('2', 'Ruapehu', 'North'),
    ('3', 'Nelson Tasman', 'South'),
    ('4', 'West Coast', 'South'),
    ('5', 'Fiordland', 'South');
    
INSERT INTO Walk_details
	(Walk_ID, Walk_name, Distance, Min_days, Max_days, Grade, Circuit_or_oneway, Closest_town, Distance_from_town_mins, Region_ID)
	VALUES
    ('1', 'Lake Waikaremoana', '46.5', '3', '4', 'Intermediate', 'Circuit', 'Napier', '140', '1'),
    ('2', 'Tongariro Northern Circuit', '43.5', '3', '4', 'Intermediate', 'Circuit', 'Taupō', '80', '2'),
    ('3', 'Whanganui Journey', '145.0', '3', '5', 'Canoe journey', 'One-way', 'Whanganui', '120', '2'),
    ('4', 'Abel Tasman Coast Track', '60.0', '3', '5', 'Easy', 'One-way', 'Nelson', '40', '3'),
    ('5', 'Heaphy Track', '78.4', '2', '6', 'Intermediate', 'One-way', 'Takaka', '60', '4'),
    ('6', 'Paparoa Track', '55.0', '2', '3', 'Intermediate', 'One-way', 'Greymouth', '40', '4'),
    ('7', 'Routeburn Track', '32.2', '2', '4', 'Intermediate', 'One-way', 'Queenstown', '45', '5'),
    ('8', 'Kepler Track', '60.2', '3', '4', 'Intermediate', 'One-way', 'Queenstown', '120', '5'),
    ('9', 'Milford Track', '53.5', '4', '4', 'Intermediate', 'One-way', 'Queenstown', '140', '5');

INSERT INTO Hut_prices
	(Walk_ID, Summer_hut_prices, Winter_hut_prices, Shoulder_hut_prices)
    VALUES
	('1', '38.0', '38.0', '38.0'),
    ('2', '44.0', '25.0', '25.0'),
    ('3', '35.0', '25.0', '25.0'),
    ('4', '50.0', '30.0', '38.0'),
    ('5', '44.0', '30.0', '38.0'),
    ('6', '58.0', '48.0', '48.0'),
    ('7', '80.0', '25.0', '30.0'),
    ('8', '80.0', '25.0', '25.0'),
    ('9', '92.0', '25.0', '25.0');
    
INSERT INTO Campsite_prices
	(Walk_ID, Summer_tent_prices, Non_summer_tent_prices)
    VALUES
	('1', '17.0', '17.0'),
    ('2', '19.0', '10.0'),
    ('3', '19.0', '12.0'),
    ('4', '19.0', '19.0'),
    ('5', '19.0', '19.0'),
    ('7', '25.0', '10.0'),
    ('8', '25.0', '10.0');

-- Add new Great Walk 'Rakiura Track' to database
INSERT INTO Region
    (Region_ID, Region, North_or_South)
    VALUES
    ('6', 'Rakiura', 'South');
    
INSERT INTO Walk_details	
(Walk_ID, Walk_name, Distance, Min_days, Max_days, Grade, Circuit_or_oneway, Closest_town, Distance_from_town_mins, Region_ID)
	VALUES
    ('10', 'Rakiura Track', '32.0', '3', '3', 'Intermediate', 'One-way', 'Bluff', '60', '6');
    
INSERT INTO Hut_prices
	(Walk_ID, Summer_hut_prices, Winter_hut_prices, Shoulder_hut_prices)
    VALUES
	('10', '44.0', '31.0', '38.0');

-- Alter column name Distance to Distance_km in table called Walk_details
ALTER TABLE Walk_details
CHANGE COLUMN Distance Distance_km FLOAT;

-- Retrieve walks that take an hour or under to drive to from the closest town
SELECT w.Walk_name, w.Distance_from_town_mins, w.Closest_town
FROM Walk_details w
WHERE Distance_from_town_mins < 61
ORDER BY Distance_from_town_mins ASC;

-- Retrieve names of the walks and the regions they are in using join
SELECT w.Walk_name, r.Region
FROM Walk_details w
INNER JOIN Region r ON w.Region_ID = r.Region_ID;

-- Retrieve all South Island walks in ascending order by distance using join
SELECT w.Walk_name, w.Distance_km
FROM Walk_details w
JOIN Region r ON w.Region_ID = r.Region_ID
WHERE r.North_or_South = 'South'
ORDER BY w.Distance_km DESC;

-- Retrieve walks that cost under $20 per night to camp in summer and are under an hour drive away
SELECT wd.Walk_name, cp.Summer_tent_prices, Distance_from_town_mins
FROM Walk_details wd
JOIN Campsite_prices cp ON wd.Walk_ID = cp.Walk_ID
WHERE cp.Summer_tent_prices < 21
AND wd.Distance_from_town_mins < 61
ORDER BY cp.Summer_tent_prices ASC;

-- Retrieve total number of walks per region using count function and join
SELECT r.Region, COUNT(w.Walk_ID) AS Total_walks
FROM Walk_details w
JOIN Region r ON w.Region_ID = r.Region_ID
GROUP BY r.Region
ORDER BY Total_walks;

-- Delete campsite costs for one walk (campsite is permenantly closed)
DELETE FROM Campsite_prices
WHERE Campsite_prices.Walk_ID = 2;

-- Calculate average price of huts in NZD across all walks using AVG and CONCAT functions
SELECT CONCAT(ROUND(AVG(Summer_hut_prices), 2), ' NZD') AS Average_summer_hut_price,
       CONCAT(ROUND(AVG(Winter_hut_prices), 2), ' NZD') AS Average_winter_hut_price,
       CONCAT(ROUND(AVG(Shoulder_hut_prices), 2), ' NZD') AS Average_shoulder_hut_price
FROM Hut_prices;

-- Convert driving distance to town from mins to hours using mathematical functions
SELECT Walk_name, ROUND(Distance_from_town_mins / 60, 1) AS Distance_from_town_hours
FROM Walk_details;

-- Stored procedure for increasing campsite costs by %
DELIMITER //

CREATE PROCEDURE IncreaseCampsiteCost(
    IN walk_id INTEGER,
    IN percentage_increase FLOAT
)
BEGIN
    UPDATE Campsite_prices
    SET Summer_tent_prices = Summer_tent_prices * (1 + percentage_increase / 100),
        Non_summer_tent_prices = Non_summer_tent_prices * (1 + percentage_increase / 100)
    WHERE Walk_ID = walk_id;
END//

DELIMITER ;

-- Increase the cost of the campsite with Walk_ID 1 by 5%
SET SQL_SAFE_UPDATES = 0;
CALL IncreaseCampsiteCost(1, 5); 
SELECT * FROM Campsite_prices;