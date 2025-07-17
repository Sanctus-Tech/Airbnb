WITH cleaned AS (
    SELECT 
        minimum_nights::INTEGER AS minimum_nights,
        price::NUMERIC AS price,
        availability_365::INTEGER AS availability_365,
        number_of_reviews::INTEGER AS number_of_reviews
    FROM airbnbs
	WHERE 
        price IS NOT NULL
        AND price::NUMERIC BETWEEN 2 AND 16000
        AND minimum_nights IS NOT NULL
        AND availability_365 IS NOT NULL
        AND number_of_reviews IS NOT NULL
),
categorized AS (
    SELECT
        CASE 
            WHEN minimum_nights <= 2 THEN '0-2 nights'
            WHEN minimum_nights <= 7 THEN '3-7 nights'
            WHEN minimum_nights <= 30 THEN '8-30 nights'
            ELSE '30+ nights'
        END AS min_nights_category,
        price,
        availability_365,
        number_of_reviews
    FROM cleaned
)

SELECT  
    min_nights_category,
    COUNT(*) AS listings,
    ROUND(AVG(price), 0) AS avg_price,
    ROUND(AVG(availability_365), 0) AS avg_availability,
    ROUND(AVG(number_of_reviews), 0) AS avg_reviews
FROM categorized
GROUP BY min_nights_category
ORDER BY 
    CASE 
        WHEN min_nights_category = '0-2 nights' THEN 1
        WHEN min_nights_category = '3-7 nights' THEN 2
        WHEN min_nights_category = '8-30 nights' THEN 3
        ELSE 4
    END;
