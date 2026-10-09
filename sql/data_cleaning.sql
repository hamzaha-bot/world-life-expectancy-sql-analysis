-- World Life Expectancy Data Cleaning

-- View dataset
SELECT *
FROM world_life_expectancy;


-- Identify duplicate Country-Year records
SELECT
    Country,
    Year,
    CONCAT(Country, Year),
    COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;


-- Identify duplicate rows using ROW_NUMBER()
SELECT *
FROM (
    SELECT
        Row_ID,
        CONCAT(Country, Year),
        ROW_NUMBER() OVER (
            PARTITION BY CONCAT(Country, Year)
            ORDER BY CONCAT(Country, Year)
        ) AS Row_Num
    FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1;


-- Remove duplicate rows
SET SQL_SAFE_UPDATES = 0;

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT
            Row_ID,
            CONCAT(Country, Year),
            ROW_NUMBER() OVER (
                PARTITION BY CONCAT(Country, Year)
                ORDER BY CONCAT(Country, Year)
            ) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_table
    WHERE Row_Num > 1
);

SET SQL_SAFE_UPDATES = 1;


-- Check for missing Status values
SELECT *
FROM world_life_expectancy
WHERE Status = ''
   OR Status IS NULL;


-- Find countries classified as Developing
SELECT DISTINCT Country
FROM world_life_expectancy
WHERE Status = 'Developing';


-- Fill missing Developing status values
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE (t1.Status = '' OR t1.Status IS NULL)
  AND t2.Status = 'Developing';


-- Fill missing Developed status values
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE (t1.Status = '' OR t1.Status IS NULL)
  AND t2.Status = 'Developed';


-- Check for missing life expectancy values
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';


-- Preview interpolation for missing life expectancy values
SELECT
    t1.Country,
    t1.Year,
    t1.`Life expectancy`,
    t2.Country,
    t2.Year,
    t2.`Life expectancy`,
    t3.Country,
    t3.Year,
    t3.`Life expectancy`,
    ROUND(
        (t2.`Life expectancy` + t3.`Life expectancy`) / 2,
        1
    ) AS Estimated_Life_Expectancy
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';


-- Fill missing life expectancy using adjacent-year averages
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` =
    ROUND(
        (t2.`Life expectancy` + t3.`Life expectancy`) / 2,
        1
    )
WHERE t1.`Life expectancy` = '';


-- Final missing-value check
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
   OR `Life expectancy` IS NULL;