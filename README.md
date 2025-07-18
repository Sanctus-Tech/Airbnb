

##  Introduction  
This project analyzes Airbnb listing data in Los Angeles to uncover key insights about:  
- **Licensed vs. Unlicensed** listings and their impact on the market  
- **Revenue by Host** to identify professional vs. casual hosts  
- **Minimum Night Requirements** and their effect on pricing and availability  
- **Activity in the Last 12 Months** to measure booking trends  
- **Host Types** (individuals vs. businesses)  

I made use of **Excel** to clean the data then used **PostgreSQL** to write the queries and finalized it with **PowerBI** to visualizes the data.  

---

##  Background  
Airbnb has transformed short-term rentals, but it also raises regulatory and economic concerns. Cities like Los Angeles enforce licensing rules to control rental markets, while hosts balance pricing, occupancy, and guest satisfaction.  

This project answers critical questions:  
**How many listings operate legally (licensed) vs. illegally (unlicensed)?**  
**Which hosts earn the most revenue, and are they individuals or businesses?**  
**Do minimum-night restrictions affect pricing and availability?**  
**Which listings are most active (recent bookings & reviews)?**  
**What percentage of hosts are commercial operators vs. casual renters?**  

---

## **Key Learnings**  

### **1. Licensed vs. Unlicensed Listings** 
- **Finding**: A significant portion of listings lack proper licensing.  
- **Insight**: Unlicensed listings may undercut legal ones, creating unfair competition.  
- **SQL Query Used**:  
```sql
SELECT 
    host_id,
    host_name,
    COUNT(*) AS total_listings,
    SUM(CASE WHEN license = 'NO LICENSE' THEN 1 ELSE 0 END) AS unlicensed_listings
FROM airbnbs
GROUP BY host_id, host_name
HAVING COUNT(*) > 1
ORDER BY total_listings DESC;
```

### **2️. Revenue by Host**  
- **Finding**: A Large percentage of hosts (often causal host) control single listing and generate the most revenue.  
- **Insight**: The market is dominated by casual hosts, not professional businesses.  
- **SQL Query Used**:  
```sql
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
  ```

### **3️. Minimum Night Analysis**  
- **Finding**: Listings with longer minimum stays (30+ nights) often have lower prices but higher occupancy.  
- **Insight**: LA’s short-term rental laws may push hosts toward long-term stays.  
- **SQL Query Used**:  
  ```sql
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
        AND number_of_reviews IS NOT NULL),categorized AS
  (
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

  ```

### **4️. Review Activity (Last 12 Months)**  
- **Finding**: Listings with frequent recent reviews have higher prices and lower availability (high demand).  
- **Insight**: Popular listings adjust pricing dynamically based on demand.  
- **SQL Query Used**:  
```sql
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

  ```

### **5. Host Type (Casual vs. Business)**  
- **Finding**: Most hosts have just 1 listing, but a few control 10+ properties.  
- **Insight**: The market has a mix of individual hosts and commercial operators.  
- **SQL Query Used**:  
```sql
  SELECT 
      CASE 
          WHEN calculated_host_listings_count = 1 THEN 'Casual Host'
          WHEN calculated_host_listings_count <= 5 THEN 'Small Business'
          ELSE 'Commercial Operator'
      END AS host_type,
      COUNT(*) AS hosts,
      AVG(price) AS avg_price
  FROM airbnbs
  GROUP BY host_type;
  ```

---

## **Conclusions**  
**Regulatory Gaps**: Many unlicensed listings operate, possibly evading taxes and regulations.  
**Revenue Concentration**: Casual hosts dominate earnings, while most professional hosts earn modestly.  
**Minimum Nights Matter**: Long-term stays (30+ nights) are common, likely due to local laws.  
**Popular Listings**: Recent activity correlates with higher prices and lower availability.  
**Host Diversity**: The market includes both casual renters and large-scale operators.  

### **Next Steps**  
- **For Hosts**: Adjust pricing strategies based on demand and competition.  
- **For Regulators**: Strengthen enforcement of licensing rules.  
- **For Travelers**: Use this data to find fairly priced, legal listings.  

This analysis provides actionable insights for hosts, policymakers, and travelers in the short-term rental market.
