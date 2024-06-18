create database videogames;
use videogames;


select count(*) from vgsales;
describe vgsales;

-- 1 Identify the top 5 games by global sales for each genre.
with rankgame as(
select Genre,Name,Global_Sales,
Row_number() over(partition by Genre order by Global_Sales desc)
as top_five_games
from vgsales)
select Genre,global_sales
from rankgame
order by global_sales desc limit 5;

-- 2 Find the publisher with the highest
--  average global sales for games released after 2000.
select publisher,avg(global_sales) as highest_avg
from vgsales
where year >2000
group by publisher
order by highest_avg desc limit 5;

-- 3 Determine the game with the largest
-- difference in sales between North America and Europe.
select name,genre,abs(North_America - Europe_sales)
as large_differnce_sales
from vgsales
order by large_differnce_sales desc limit 1;

alter table vgsales
rename column European_Sales to Europe_sales;

-- 4 Calculate the total sales for each genre 
-- across all regions and identify which genre has the highest sales.
select genre,
sum(North_America + Europe_sales+Japan_sales+other_sales+Global_sales)
as total_sales
from vgsales 
group by genre
order by total_sales desc limit 5;

-- 5 Find the year with the highest number of game releases 
-- and list the top 3 games by global sales from that year.
select year,count(*) as games_released
from vgsales
group by year
order by games_released desc limit 3;

-- 6  Identify the platform with the highest
--  total sales and list the top 5 games contributing to those sales.
WITH highest_sales_platform AS (
SELECT Platform
FROM vgsales
GROUP BY Platform
ORDER BY SUM(North_America + Europe_sales + Japan_Sales + Other_Sales) DESC
LIMIT 1
)
SELECT Name,(North_America + Europe_sales + Japan_Sales + Other_Sales)AS total_sales
FROM vgsales
WHERE Platform = (SELECT Platform FROM highest_sales_platform)
ORDER BY total_sales DESC
LIMIT 5;

-- 7 Calculate the average sales for each genre and compare it with the overall average sales for all games.
-- CTE to calculate the average sales for each genre
WITH GenreAvg AS (
SELECT Genre, AVG(Global_Sales) AS Avg_Sales
FROM vgsales
GROUP BY Genre),
-- CTE to calculate the overall average sales
OverallAvg AS (
    SELECT AVG(Global_Sales) AS Overall_Avg_Sales
    FROM vgsales
)
-- Main query to compare genre averages with the overall average
SELECT ga.Genre, ga.Avg_Sales, oa.Overall_Avg_Sales, 
ga.Avg_Sales - oa.Overall_Avg_Sales AS Difference
FROM GenreAvg ga, OverallAvg oa;

--  8 Determine the top 10 publishers by the total number of games released and their respective total global sales.
select publisher,count(*) as total_games,sum(global_sales)
 as total_global_sales
from vgsales
group by publisher
order by total_global_sales desc limit 10;

--  9 Find the game with the highest sales in Japan and compare its sales with the global sales of the top 5 games in the same genre.
WITH japan_highest_sales AS (
    SELECT *
    FROM vgsales
    WHERE japan_sales = (
        SELECT MAX(japan_sales)
        FROM vgsales
    )
), 
japan_genre AS (
    SELECT genre
    FROM japan_highest_sales
), 
global_top_games AS (
    SELECT genre, name, global_sales
    FROM vgsales
    WHERE genre IN (SELECT genre FROM japan_genre)
    ORDER BY global_sales DESC
    LIMIT 5
)

SELECT japan_highest_sales.name AS japan_highest_sales_game,
       japan_highest_sales.japan_sales AS japan_sales,
       global_top_games.name AS global_top_game,
       global_top_games.global_sales AS global_sales
FROM japan_highest_sales, global_top_games;


-- 10 Identify the game with the lowest sales in each region (North America, Europe, Japan, and Other) and compare their global sales.
WITH LowestSales AS (
    SELECT 
        MIN(North_America) AS Lowest_NA_Sales,
        MIN(Europe_Sales) AS Lowest_Europe_Sales,
        MIN(Japan_Sales) AS Lowest_Japan_Sales,
        MIN(Other_Sales) AS Lowest_Other_Sales,
        MIN(Global_Sales) AS Lowest_Global_Sales
    FROM 
       vgsales
)
SELECT 
  
    North_America,
    Europe_Sales,
    Japan_Sales,
    Other_Sales,
    Global_Sales,
    (SELECT Lowest_Global_Sales FROM LowestSales) AS Lowest_Global_Sales
FROM 
    vgsales
WHERE 
    North_America = (SELECT Lowest_NA_Sales FROM LowestSales)
    OR Europe_Sales = (SELECT Lowest_Europe_Sales FROM LowestSales)
    OR Japan_Sales = (SELECT Lowest_Japan_Sales FROM LowestSales)
    OR Other_Sales = (SELECT Lowest_Other_Sales FROM LowestSales);


-- 11 Calculate the percentage of total global sales contributed by the top 3 platforms.

WITH Top3Platforms AS (
    SELECT 
        Platform,
        SUM(Global_Sales) AS Total_Sales
    FROM 
       vgsales
    GROUP BY 
        Platform
    ORDER BY 
        Total_Sales DESC
    LIMIT 3
)
SELECT 
    (SELECT SUM(Total_Sales) FROM Top3Platforms) AS Total_Top3_Sales,
    (SELECT SUM(Global_Sales) FROM vgsales) AS Total_Global_Sales,
    ((SELECT SUM(Total_Sales) FROM Top3Platforms) / (SELECT SUM(Global_Sales) FROM vgsales)) * 100 AS Percentage_Contribution;
    
-- 12 Determine the correlation between 
-- North American and European sales for all games
SELECT(
SUM((North_america - NA_mean) * (Europe_sales - EU_mean)) / 
(SQRT(SUM(POWER(North_america - NA_mean, 2)) * 
SUM(POWER(Europe_sales - EU_mean, 2))))) AS correlation_coefficient
FROM(
SELECT 
AVG(North_america) AS NA_mean,
AVG(Europe_sales) AS EU_mean
FROM vgsales
) AS subquery, vgsales;



-- 13 Find the genre that has the highest 
-- number of games with global sales greater than 10 million.
SELECT genre, COUNT(*) AS num_games
FROM vgsales
WHERE global_sales > 10
GROUP BY genre
ORDER BY num_games DESC
LIMIT 1;


-- 14 Identify the top 5 games with the highest increase in sales from Japan to global sales and analyze their genres.
SELECT name,genre, (global_sales - japan_sales) AS sales_increase
FROM vgsales
ORDER BY sales_increase DESC
LIMIT 5;

-- 15 Calculate the median sales for each 
-- region and compare it with the average sales
--  for those regions.Calculate median sales for each region

SELECT 
    AVG(Japan_sales) AS average_sales,
    AVG(Japan_sales) AS median_sales
FROM (
    SELECT 
        Japan_sales,
        ROW_NUMBER() OVER (ORDER BY Japan_sales) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM vgsales
) AS MedianCTE
WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2);

    
    
-- 16 Find the year with the highest average 
-- global sales for games and list the top 5 games from that year.
-- Find the year with the highest average global sales
SELECT Year, AVG(Global_Sales) AS Average_Global_Sales
FROM vgsales
GROUP BY Year
ORDER BY Average_Global_Sales DESC
LIMIT 1;

-- List the top 5 games from the year with the highest average global sales
SELECT name, Global_Sales
FROM vgsales
WHERE Year = (SELECT Year
FROM (SELECT Year, AVG(Global_Sales) AS Average_Global_Sales
FROM vgsales
GROUP BY Year
ORDER BY Average_Global_Sales DESC
LIMIT 1) AS Highest_Average_Year)
ORDER BY Global_Sales DESC LIMIT 5;

-- 17 Identify the top 5 genres with the highest sales in the "Other" region and analyze the publishers for these genres.
-- Identify the top 5 genres with the highest sales in the "Other" region

SELECT Genre, SUM(Other_Sales) AS Total_Other_Sales, Publisher, SUM(Other_Sales) AS Publisher_Other_Sales
FROM vgsales
GROUP BY Genre, Publisher
ORDER BY Total_Other_Sales DESC, Publisher_Other_Sales DESC
LIMIT 5;

-- 18  Calculate the standard deviation of global sales for games released by Nintendo and compare it with the standard deviation of global sales for all other publishers.
-- Calculate the standard deviation of global sales for games released by Nintendo
SELECT 
    'Nintendo' AS Publisher,
    STDDEV(Global_Sales) AS StdDev_Nintendo
FROM 
    vgsales
WHERE 
    Publisher = 'Nintendo'

UNION

-- Calculate the standard deviation of global sales for all other publishers
SELECT 
    'Other Publishers' AS Publisher,
    STDDEV(Global_Sales) AS StdDev_OtherPublishers
FROM 
    vgsales
WHERE 
    Publisher != 'Nintendo';

-- 19 Determine the game with the highest combined sales in North America and Europe and compare its sales with the top-selling game in Japan.
-- Find the game with the highest combined sales in North America and Europe
WITH CombinedSales AS (
    SELECT name, (north_america + Europe_Sales) AS Combined_Sales
    FROM vgsales
    ORDER BY Combined_Sales DESC
    LIMIT 1
)
SELECT CS.name AS Top_Game_Combined,
       CS.Combined_Sales AS Combined_Sales,
       (SELECT name FROM vgsales ORDER BY Japan_Sales DESC LIMIT 1) AS Top_Game_Japan,
       (SELECT Japan_Sales FROM vgsales ORDER BY Japan_Sales DESC LIMIT 1) AS Japan_Sales
FROM CombinedSales CS;


-- 20  Find the top 10 games by global sales 
-- and analyze their sales distribution across different regions.

WITH Top10Games AS (
SELECT Name, Global_Sales, North_America, Europe_Sales, Japan_Sales, Other_Sales
FROM vgsales
ORDER BY Global_Sales DESC LIMIT 10
)
SELECT 
TG.Name,TG.Global_Sales,
TG.Global_Sales - (TG.North_America + TG.Europe_Sales + TG.Japan_Sales + TG.Other_Sales) AS Unknown_Sales,
TG.North_America AS North_America,
TG.Europe_Sales AS Europe_Sales,
TG.Japan_Sales AS Japan_Sales,
TG.Other_Sales AS Other_Sales
FROM  Top10Games TG;
