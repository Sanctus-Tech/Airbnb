SELECT SUM(price * (365 - availability_365)) AS estimated_revenue
FROM airbnbs
WHERE price IS NOT NULL AND availability_365 IS NOT NULL;


