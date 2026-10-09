-- World Life Expectancy Exploratory Data Analysis


-- Life expectancy increase by country
SELECT
    Country,
    MIN(`Life expectancy`) AS Min_Life_Expectancy,
    MAX(`Life expectancy`) AS Max_Life_Expectancy,
    ROUND(
        MAX(`Life expectancy`) - MIN(`Life expectancy`),
        1
    ) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
   AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years ASC;


-- Average life expectancy by year
SELECT
    Year,
    ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Expectancy
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;


-- Life expectancy compared with GDP by country
SELECT
    Country,
    ROUND(AVG(`Life expectancy`), 1) AS Life_Exp,
    ROUND(AVG(GDP), 1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
   AND GDP > 0
ORDER BY GDP DESC;


-- High GDP vs Low GDP life expectancy
SELECT
    SUM(
        CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END
    ) AS High_GDP_Count,

    AVG(
        CASE
            WHEN GDP >= 1500 THEN `Life expectancy`
            ELSE NULL
        END
    ) AS High_GDP_Life_Expectancy,

    SUM(
        CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END
    ) AS Low_GDP_Count,

    AVG(
        CASE
            WHEN GDP <= 1500 THEN `Life expectancy`
            ELSE NULL
        END
    ) AS Low_GDP_Life_Expectancy

FROM world_life_expectancy;


-- Average life expectancy by development status
SELECT
    Status,
    ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Status;


-- Country count and life expectancy by development status
SELECT
    Status,
    COUNT(DISTINCT Country) AS Country_Count,
    ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Status;


-- Life expectancy compared with BMI
SELECT
    Country,
    ROUND(AVG(`Life expectancy`), 1) AS Life_Exp,
    ROUND(AVG(BMI), 1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
   AND BMI > 0
ORDER BY BMI DESC;


-- Rolling adult mortality for countries containing "United"
SELECT
    Country,
    Year,
    `Life expectancy`,
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER (
        PARTITION BY Country
        ORDER BY Year
    ) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE '%United%';