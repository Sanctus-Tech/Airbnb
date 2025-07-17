WITH host_stats AS (
    SELECT 
        host_id,
        host_name,
        COUNT(*) AS listings_owned,
        AVG(price) AS avg_price,
        SUM(365 - availability_365) AS estimated_booked_days
    FROM airbnbs
    GROUP BY host_id, host_name
)

SELECT 
    CASE 
        WHEN listings_owned = 1 THEN 'Casual Host'
        WHEN listings_owned BETWEEN 2 AND 5 THEN 'Small Business'
        ELSE 'Professional Business'
    END AS host_type,
    COUNT(*) AS number_of_hosts,
    ROUND(AVG(listings_owned), 1) AS avg_listings,
    ROUND(AVG(avg_price), 2) AS avg_price,
    SUM(estimated_booked_days * avg_price) AS estimated_annual_revenue
FROM host_stats
GROUP BY host_type
ORDER BY estimated_annual_revenue DESC;