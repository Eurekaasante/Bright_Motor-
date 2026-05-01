SELECT 
    -- 1. GROUPING DIMENSIONS (Null-Protected)
    COALESCE(CAST(EXTRACT(YEAR FROM SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', TRIM(saledate))) AS STRING), 'Unknown') AS sale_year, 
    COALESCE(EXTRACT(MONTH FROM SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', TRIM(saledate))), 0) AS month_num, 
    COALESCE(FORMAT_TIMESTAMP('%b', SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', TRIM(saledate))), 'Unknown') AS month_name, 
    COALESCE(state, 'Unknown') AS state, 
    COALESCE(make, 'Not defined') AS make, 
    COALESCE(model, 'Unspecified') AS model, 
    CASE 
        WHEN LOWER(body) IN ('sedan', 'coupe', 'convertible') THEN 'sedan' 
        WHEN LOWER(body) IN ('suv', 'crossover') THEN 'suv' 
        WHEN LOWER(body) IN ('van', 'minivan', 'cargo van', 'super cab') THEN 'ldv' 
        WHEN LOWER(body) IN ('crew cab', 'extended cab', 'supercab', 'pickup') THEN 'heavy duty' 
        ELSE 'other' 
    END AS vehicle_category, 
    CASE 
        WHEN LOWER(COALESCE(color, 'unknown')) IN ('black', 'charcoal', 'dark gray') THEN 'dark tone' 
        WHEN LOWER(COALESCE(color, 'unknown')) IN ('white', 'silver', 'gray', 'pearl') THEN 'bright tone' 
        WHEN LOWER(COALESCE(color, 'unknown')) IN ('red', 'burgundy', 'maroon') THEN 'red tone' 
        WHEN LOWER(COALESCE(color, 'unknown')) IN ('blue', 'navy', 'azure') THEN 'blue tone' 
        ELSE 'other/custom' 
    END AS color_group, 
    CASE 
        WHEN condition >= 20 THEN 'excellent' 
        WHEN condition BETWEEN 10 AND 19.9 THEN 'good' 
        WHEN condition < 9.9 THEN 'fair' 
        ELSE 'not rated' 
    END AS condition_tier,

    -- 2. AGGREGATED METRICS
    COUNT(*) AS total_units_sold,
    ROUND(AVG(IFNULL(sellingprice, 0)), 2) AS avg_selling_price,
    ROUND(AVG(IFNULL(mmr, 0)), 2) AS avg_market_estimate,
    SUM(IFNULL(sellingprice, 0)) AS total_revenue,
    ROUND(AVG(IFNULL(odometer, 0)), 0) AS avg_mileage

FROM `uscarsales.salesdata.BMAnalyse`
GROUP BY 
    sale_year, 
    month_num, 
    month_name, 
    state, 
    make, 
    model, 
    vehicle_category, 
    color_group, 
    condition_tier;
