SELECT * FROM `uscarsales.salesdata.BMAnalyse` LIMIT 10;

--------------------
--DATE EXPLORATION
--------------------


SELECT 
    COUNT(*) AS total_records, 
    COUNT(DISTINCT make) AS unique_brands
FROM `uscarsales.salesdata.BMAnalyse`;

--there are 96 unique car barnds in the dataset

SELECT 
    MAX(sellingprice) AS highest_price, 
    MIN(sellingprice) AS lowest_price,
    MAX(year) AS newest_car,
    MIN(year) AS oldest_car
FROM `uscarsales.salesdata.BMAnalyse`;

--the most expensive car is 230000 and cheapest is 1, while the newest model is 2015 and 1982 is the oldest model.

SELECT 
    AVG(sellingprice) AS avg_selling_price, 
    AVG(odometer) AS avg_mileage
FROM `uscarsales.salesdata.BMAnalyse`;

--the average selling price is 13611 and average mileage is 68323 


SELECT 
    age_bracket,
    COUNT(*) AS units_sold,
    ROUND(AVG(Sellingprice), 2) AS avg_price
FROM `uscarsales.salesdata.BMAnalyse_Rev1`
GROUP BY age_bracket
ORDER BY units_sold DESC;




---------------------------
--Data Enrichment
--------------------------

SELECT AVG(Sellingprice) AS Average_Price
FROM `uscarsales.salesdata.BMAnalyse`;
--The average sell price is 13611

---------------------------------
--REVENUE BY CAR MAKE/MODEL
--------------------------------

SELECT DISTINCT Model, 
SUM(Sellingprice) AS Total_Revenue
FROM `uscarsales.salesdata.BMAnalyse_GOLD`
GROUP BY Model
ORDER BY Total_Revenue DESC;

SELECT DISTINCT `trim`, 
SUM(Sellingprice) AS Total_Revenue
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY `trim`
ORDER BY Total_Revenue DESC;

-----------------------------
--SALES DISTRIBUTION BY YEAR
----------------------------

SELECT `Year`, COUNT(*) AS Sales_Count
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY `Year` 
ORDER BY `Year`;


----------------------------
--CALCULATE SALES PRICE X Unit SOLD
-----------------------------------

SELECT Body,
        Model,
    SUM(Sellingprice) AS Total_Revenue,
    COUNT(*) AS Total_Units_Sold
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY Model, Body
ORDER BY Body, model DESC;



SELECT *
FROM `uscarsales.salesdata.BMAnalyse`
LIMIT 3;

-----------------------------
--Car sales by state
----------------------------

SELECT 
    State, 
    COUNT(*) AS Units_Sold, 
    SUM(Sellingprice) AS Total_Revenue,
    AVG(Condition) AS Avg_Condition
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY State
ORDER BY Total_Revenue DESC;




--------------------------------
--Vehicle model by Marging percent
----------------------------------

SELECT 
    Model,
    Sellingprice,
    MMR,
    ((Sellingprice - MMR) / NULLIF(Sellingprice, 0)) * 100 AS Margin_Percent
FROM `uscarsales.salesdata.BMAnalyse`;




-----------------------------
--Vehicle sales by month
----------------------------
SELECT 
    EXTRACT(YEAR FROM SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', TRIM(Saledate))) AS year,
    EXTRACT(MONTH FROM SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', TRIM(Saledate))) AS month,
    SUM(Sellingprice) AS total_sales
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY year, month
HAVING year IS NOT NULL  
ORDER BY year, month;


-------------------------------
--vehicle by state
------------------------------

SELECT 
    state, 
    body AS vehicle_type, 
    COUNT(*) AS vehicle_count
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY state, vehicle_type
ORDER BY state, vehicle_count DESC;

------------------------------
--Vehicles by model type
-----------------------------

SELECT 
    year, 
    model, 
    trim,
    body, 
    COUNT(*) as total_count,
    ROUND(AVG(Sellingprice), 2) as avg_price
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY year, model, trim, body
ORDER BY total_count DESC;


-----------------------------
--Price Categorisation
-----------------------------

SELECT 
    Body, 
    model, 
    Sellingprice,
    CASE 
        WHEN Sellingprice < 10000 THEN 'Budget'
        WHEN Sellingprice BETWEEN 10000 AND 30000 THEN 'Mid-Range'
        WHEN Sellingprice > 30000 THEN 'Premium'
        ELSE 'Check Price'
    END AS price_category

FROM `uscarsales.salesdata.BMAnalyse`;

------------------------------
--Condition Tiers
-----------------------------

SELECT 
    Body, 
    model, 
    condition,
    CASE 
        WHEN condition >= 20 THEN 'Excellent'
        WHEN condition BETWEEN 10.0 AND 19.9 THEN 'Good/Average'
        WHEN condition < 10.0 THEN 'Poor'
        ELSE 'No Condition Data'
    END AS condition_tier
FROM `uscarsales.salesdata.BMAnalyse`;

-------------------------------
-- Age Categorisation
-------------------------------

SELECT 
    Body, 
    model, 
    Year,
    CASE 
        WHEN Year >= 2015 THEN 'Newer Model'
        WHEN Year BETWEEN 2010 AND 2014 THEN 'Mid-Age'
        ELSE 'Older Model'
    END AS age_bracket
FROM `uscarsales.salesdata.BMAnalyse`;


-----------------------
--Recheck the nulls
----------------------


SELECT 
    Saledate, 
    COUNT(*) as frequency
FROM `uscarsales.salesdata.BMAnalyse`
WHERE SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', TRIM(Saledate)) IS NULL
GROUP BY Saledate
LIMIT 10;

------------------------------
--Checking missing values
-----------------------------
SELECT 
    COUNT(*) AS total_rows,
    COUNTIF(Saledate IS NULL) AS missing_dates,
    COUNTIF(body IS NULL) AS missing_makes,
    COUNTIF(model IS NULL) AS missing_models,
    COUNTIF(Sellingprice IS NULL OR Sellingprice = 0) AS invalid_prices,
    COUNTIF(state IS NULL) AS missing_states,
    COUNTIF(MMR IS NULL) AS missing_mmr_data
FROM `uscarsales.salesdata.BMAnalyse`;

--the data is skewed because of the inherent error with 12 missing dates, and 12 invalid prices followed by 131 195 missing models/body type and 103 99 missing models and 12 missing MMR, 


SELECT SUBSTR(vin, 4, 5) AS engine_vds_code, COUNT(*) AS volume
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY engine_vds_code ORDER BY volume DESC LIMIT 10;



SELECT color, 
    CASE 
    WHEN color IN ('Black', 'White', 'Silver', 'Gray') THEN 'Neutral'
    ELSE 'Unique/Bright' END AS color_group,
    COUNT(*) as count
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY color, color_group ORDER BY count DESC;


SELECT transmission, seller, 
    AVG(sellingprice) as avg_price, 
    COUNT(*) as units
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY transmission, seller;

--------------------------
--FIXING THE NULLS
--------------------------

SELECT 
    -- 1. Identity & Technical (Replacing Blanks with 'Unknown')
    IFNULL(NULLIF(vin, ''), 'MISSING_VIN') AS vin,
    IFNULL(NULLIF(make, ''), 'Unknown Make') AS make,
    IFNULL(NULLIF(model, ''), 'Unknown Model') AS model,
    IFNULL(NULLIF(body, ''), 'Unknown Body') AS body,
    IFNULL(NULLIF(transmission, ''), 'Not Specified') AS transmission,
    IFNULL(NULLIF(color, ''), 'N/A') AS color,
    IFNULL(NULLIF(seller, ''), 'Private Seller') AS seller,
    IFNULL(NULLIF(state, ''), 'XX') AS state,

    -- 2. Numerical Metrics (Replacing NULLs with 0 or Mean)
    COALESCE(condition, 0) AS condition,
    COALESCE(odometer, 0) AS odometer,
    COALESCE(mmr, 0) AS mmr,
    COALESCE(sellingprice, 0) AS sellingprice,

    -- 3. Dates (Replacing Missing with Placeholder)
    IFNULL(NULLIF(saledate, ''), 'Sun Jan 01 2000 00:00:00') AS saledate

FROM `uscarsales.salesdata.BMAnalyse`;



SELECT 
    state,
    COUNT(*) AS total_cars,
    COUNT(DISTINCT model) AS model_variety,
    MIN(sellingprice) AS min_price,
    MAX(sellingprice) AS max_price,
    ROUND(AVG(sellingprice), 2) AS mean_price
FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY state
ORDER BY total_cars DESC;


SELECT 
    vin, 
    make, 
    model,


-- 2. VIN EXTRACTION (8th Digit = Engine/Fuel Code)
    SUBSTR(vin, 8, 1) AS engine_code,

    
    CASE 
        -- Common Diesel Indicators in VIN 8th position (1, D, V, 2)
        WHEN SUBSTR(vin, 8, 1) IN ('1', 'D', 'V', '2') THEN 'Diesel'
        -- Hybrid/Electric check based on model keywords or VIN codes
        WHEN LOWER(model) LIKE '%hybrid%' OR SUBSTR(vin, 8, 1) IN ('H', 'E') THEN 'Hybrid/Electric'
        -- Flex Fuel / E85 common codes
        WHEN SUBSTR(vin, 8, 1) IN ('Z', 'F', 'C') THEN 'Flex-Fuel (E85/Petrol)'
        -- Default to Petrol for standard passenger cars
        ELSE 'Petrol'
    END AS fuel_type_from_vin
     FROM `uscarsales.salesdata.BMAnalyse`;


------------------------------------------
--Create a new table for further analysis
------------------------------------------

CREATE OR REPLACE TABLE `uscarsales.salesdata.bmanalyse_Rev1` AS
SELECT 
    -- 1. Identity & Technical (Original Track)
    IFNULL(NULLIF(vin, ''), 'missing_vin') AS vin,
    LOWER(IFNULL(NULLIF(make, ''), 'unknown make')) AS make,
    LOWER(IFNULL(NULLIF(model, ''), 'unknown model')) AS model,
    LOWER(IFNULL(NULLIF(body, ''), 'unknown body')) AS body,
    LOWER(IFNULL(NULLIF(transmission, ''), 'not specified')) AS transmission,
    UPPER(IFNULL(NULLIF(state, ''), 'xx')) AS state,
    
    -- 2. VIN DECODING (Engine Code extraction)
    SUBSTR(vin, 8, 1) AS engine_code,

    -- 3. FUEL TYPE & ENGINE CAPACITY (The "Main" logic)
    CASE 
        -- Common Proxy for Heavy/High Capacity (Diesel)
        WHEN LOWER(body) IN ('truck', 'van', 'pickup') OR SUBSTR(vin, 8, 1) IN ('1', '2', 'D') THEN 'Diesel - High Capacity'
        -- Common Proxy for Economy/Standard (Petrol)
        WHEN LOWER(body) IN ('sedan', 'hatchback', 'coupe') THEN 'Petrol - Standard Capacity'
        -- Hybrid/Electric Indicators
        WHEN LOWER(model) LIKE '%hybrid%' OR LOWER(body) LIKE '%electric%' THEN 'Hybrid/Electric'
        ELSE 'Petrol - Moderate Capacity'
    END AS fuel_type,

    -- 4. DETAILED CONDITION (Excellent to Poor)
    CASE 
        WHEN condition >= 4.5 THEN 'Excellent'
        WHEN condition >= 3.5 THEN 'Good'
        WHEN condition >= 2.5 THEN 'Average'
        WHEN condition >= 1.5 THEN 'Fair'
        WHEN condition > 0 THEN 'Poor'
        ELSE 'Unknown/Salvage'
    END AS condition_label,

    -- 5. FINANCIALS & MARGINS
    COALESCE(sellingprice, 0) AS selling_price,
    COALESCE(mmr, 0) AS mmr,
    (sellingprice - mmr) AS margin_amount,
    ROUND(SAFE_DIVIDE((sellingprice - mmr), NULLIF(mmr, 0)) * 100, 2) AS margin_percentage,

    -- 6. INVENTORY & LEVEL 1 EDA (State & Global context)
    COUNT(*) OVER(PARTITION BY state) AS inventory_by_state,
    SUM(sellingprice) OVER() AS total_revenue,
    AVG(sellingprice) OVER() AS avg_market_price

FROM `uscarsales.salesdata.BMAnalyse`;


-------------------------------
--CONSOLIDATED CODE
------------------------------


CREATE OR REPLACE TABLE `uscarsales.salesdata.bmanalyse_Rev1` AS
SELECT 
    
    UPPER(IFNULL(NULLIF(state, ''), 'XX')) AS state,
    LOWER(IFNULL(NULLIF(make, ''), 'unknown make')) AS make,
    LOWER(IFNULL(NULLIF(body, ''), 'unknown body')) AS body,
    
    
    CASE 
        WHEN SUBSTR(vin, 8, 1) IN ('1', 'D', 'V', '2') THEN 'Diesel'
        WHEN SUBSTR(vin, 8, 1) IN ('H', 'E') OR LOWER(model) LIKE '%hybrid%' THEN 'Hybrid/Electric'
        ELSE 'Petrol'
    END AS fuel_type,

    
    CASE 
        WHEN condition >= 4.5 THEN 'Excellent'
        WHEN condition >= 3.5 THEN 'Good'
        WHEN condition >= 2.5 THEN 'Average'
        ELSE 'Fair/Poor'
    END AS condition_grade,

    
    COUNT(*) AS total_inventory_count,
    SUM(sellingprice) AS total_revenue,
    ROUND(AVG(sellingprice), 2) AS avg_selling_price,
    ROUND(AVG(mmr), 2) AS avg_mmr_value,
    ROUND(AVG(sellingprice - mmr), 2) AS avg_profit_margin

FROM `uscarsales.salesdata.BMAnalyse`

GROUP BY 
    state, 
    make, 
    body, 
    fuel_type, 
    condition_grade;




    CREATE OR REPLACE TABLE `uscarsales.salesdata.bmanalyse_Rev1` AS
SELECT 
    
       -- 1. CLEANED DIMENSIONS
    UPPER(IFNULL(NULLIF(state, ''), 'XX')) AS state,
    LOWER(IFNULL(NULLIF(make, ''), 'unknown make')) AS make,
    LOWER(IFNULL(NULLIF(body, ''), 'unknown body')) AS body,
    
    -- CASE 1: CONDITION GRADE
    CASE 
        WHEN COALESCE(condition, 0) >= 25 THEN 'Excellent'
        WHEN COALESCE(condition, 0) BETWEEN 15 AND 24.9 THEN 'Good'
        WHEN COALESCE(condition, 0)<14.9 THEN 'Average'
        ELSE 'Fair/Poor'
    END AS condition_grade,

    -- CASE 2: PRICE TIERS
    CASE 
        WHEN COALESCE(sellingprice, 0) >= 50000 THEN 'Luxury'
        WHEN COALESCE(sellingprice, 0) >= 20000 THEN 'Mid-Range'
        ELSE 'Economy'
    END AS price_tier,

    -- CASE 3: FUEL TYPE (Directly from VIN 8th digit)
    CASE 
        WHEN SUBSTR(vin, 8, 1) IN ('1', 'D', 'V', '2') THEN 'Diesel'
        WHEN SUBSTR(vin, 8, 1) IN ('H', 'E') OR LOWER(model) LIKE '%hybrid%' THEN 'Hybrid/Electric'
        ELSE 'Petrol'
    END AS fuel_type_from_vin,

    -- CASE 4: MARKET APPEAL (Based on Color)
    CASE 
        WHEN LOWER(IFNULL(color, '')) IN ('white', 'black', 'silver', 'gray') THEN 'High Demand (Neutral)'
        ELSE 'Standard Demand'
    END AS market_appeal,

    -- 2. CLEANED AGGREGATIONS (The math)
    COUNT(*) AS total_units,
    SUM(COALESCE(sellingprice, 0)) AS total_revenue,
    ROUND(AVG(COALESCE(sellingprice, 0)), 2) AS avg_selling_price,
    ROUND(AVG(COALESCE(sellingprice, 0) - COALESCE(mmr, 0)), 2) AS avg_profit_margin

FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY 
        market_appeal,
        state, 
        make, 
        body, 
        year,
        fuel_type_from_vin,
        condition_grade,
        price_tier;












   


