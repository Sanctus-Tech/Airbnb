SELECT 
    host_id,
    host_name,
    COUNT(*) AS total_listings,
    SUM(CASE WHEN license = 'NO LICENSE' THEN 1 ELSE 0 END) AS unlicensed_listings
FROM airbnbs
GROUP BY host_id, host_name
HAVING COUNT(*) > 1
ORDER BY total_listings DESC;
