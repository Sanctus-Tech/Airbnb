SELECT 
    neighbourhood_group,
    ROUND(AVG(number_of_reviews_ltm)) AS avg_reviews_last_year,
    ROUND(AVG(reviews_per_month), 1) AS avg_monthly_reviews,
    ROUND(AVG(price)) AS avg_price,
    COUNT(*) AS listings
FROM (
    SELECT 
        neighbourhood_group,
        price::NUMERIC AS price,
        number_of_reviews_ltm::INTEGER AS number_of_reviews_ltm,
        reviews_per_month::NUMERIC AS reviews_per_month
    FROM airbnbs
    WHERE 
        price IS NOT NULL AND price BETWEEN 5 AND 15000
        AND number_of_reviews_ltm IS NOT NULL
        AND reviews_per_month BETWEEN 1 AND 5
) sub
WHERE price BETWEEN 5 AND 15000
GROUP BY neighbourhood_group
ORDER BY avg_reviews_last_year DESC;
