SELECT 

    ROUND(MIN(price)::numeric, 2) AS minimum_price,
    ROUND(MAX(price)::numeric, 2) AS maximum_price,
    ROUND(AVG(price)::numeric, 2) AS average_price,
    ROUND(
        (PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price))::numeric, 
        2
    ) AS median_price,

    ROUND((MAX(price) - MIN(price))::numeric, 2) AS price_range,
    ROUND(STDDEV(price)::numeric, 2) AS price_standard_deviation,
    
    COUNT(*) AS total_listings,
    COUNT(DISTINCT host_id) AS unique_hosts
FROM 
    airbnbs
WHERE 
    price > 0 
    AND price < 15000;  