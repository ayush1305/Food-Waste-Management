--How many food providers and receivers are there in each city?
SELECT
    COALESCE(p.city, r.city) AS city,
    COALESCE(p.provider_count, 0) AS provider_count,
    COALESCE(r.receiver_count, 0) AS receiver_count
FROM
(
    SELECT city, COUNT(*) AS provider_count
    FROM providers_data
    GROUP BY city
) p
FULL OUTER JOIN
(
    SELECT city, COUNT(*) AS receiver_count
    FROM receivers_data
    GROUP BY city
) r
ON p.city = r.city
ORDER BY city;
--Which type of food provider (restaurant, grocery store, etc.) contributes the most food?
select provider_type,sum(quantity) as Total_Quantity from food_listings_data
group by provider_type
order by Total_quantity desc
limit 1;
--What is the contact information of food providers in a specific city?
select name,city,contact from providers_data
where city = 'New Jessica';
--Which receivers have claimed the most food?
select r.receiver_id,r.name,sum(f.quantity) as total_food_claimed from receivers_data r
join claims_data c
on r.receiver_id = c.receiver_id
join food_listings_data f
on c.food_id = f.food_id
group by r.receiver_id,r.name
order by total_food_claimed desc;
--FOOD LISTINGS & AVAILABILITY
--What is the total quantity of food available from all providers?
select p.provider_id,p.name,sum(f.quantity) as total_available_food from providers_data p
join food_listings_data f
on p.provider_id = f.provider_id
group by p.provider_id,p.name
order by total_available_food desc;
--Which city has the highest number of food listings?
select p.city,count(*) as total_food_listing from food_listings_data f
join providers_data p
on f.provider_id = p.provider_id
group by p.city
order by total_food_listing desc
limit 1;
--What are the most commonly available food types?
select food_type, count(*) as total_listing
from food_listings_data
group by food_type
order by total_listing desc;
--CLAIMS & DISTRIBUTION
--How many food claims have been made for each food item?
SELECT c.food_id,f.food_name,COUNT(c.claim_id) AS total_claims
FROM claims_data c
JOIN food_listings_data f
ON c.food_id = f.food_id
GROUP BY c.food_id, f.food_name
ORDER BY total_claims DESC;
--Which provider has had the highest number of successful food claims?
select p.provider_id,p.name,count(c.claim_id) as Total_Food_claims
from providers_data p
join food_listings_data f
on p.provider_id = f.provider_id
join claims_data c
on c.food_id = f.food_id
where c.status = 'Completed'
group by p.provider_id,p.name
order by Total_Food_claims desc
limit 1;
--What percentage of food claims are completed vs. pending vs. canceled?
SELECT status,ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM claims_data), 2) AS percentage
FROM claims_data
GROUP BY status
ORDER BY percentage DESC;
--ANALYSIS & INSIGHTS
--What is the average quantity of food claimed per receiver?
SELECT AVG(total_claimed) AS avg_quantity_per_receiver
FROM (
    SELECT c.receiver_id,
           SUM(f.quantity) AS total_claimed
    FROM claims_data c
    JOIN food_listings_data f
        ON c.food_id = f.food_id
    GROUP BY c.receiver_id
) t;
--Which meal type (breakfast, lunch, dinner, snacks) is claimed the most?
select f.meal_type,sum(f.quantity) as Total_Food_claimed from food_listings_data f
group by f.meal_type
order by Total_Food_Claimed desc;
--What is the total quantity of food donated by each provider?
select p.provider_id,p.name,sum(f.quantity) as total_food_donated from providers_data p
join food_listings_data f
on p.provider_id = f.provider_id
group by p.provider_id,p.name
order by total_food_donated desc;
-- KPI 1: Total Providers
SELECT COUNT(*) AS total_providers
FROM providers_data;

-- KPI 2: Total Receivers
SELECT COUNT(*) AS total_receivers
FROM receivers_data;

-- KPI 3: Total Food Listings
SELECT COUNT(*) AS total_food_listings
FROM food_listings_data;

-- KPI 4: Total Claims
SELECT COUNT(*) AS total_claims
FROM claims_data;

-- KPI 5: Total Food Quantity Available
SELECT SUM(quantity) AS total_food_quantity
FROM food_listings_data;

-- KPI 6: Total Successful Claims
SELECT COUNT(*) AS successful_claims
FROM claims_data
WHERE status = 'Completed';

-- KPI 7: Total Pending Claims
SELECT COUNT(*) AS pending_claims
FROM claims_data
WHERE status = 'Pending';

-- KPI 8: Total Cancelled Claims
SELECT COUNT(*) AS cancelled_claims
FROM claims_data
WHERE status = 'Cancelled';

-- KPI 9: Claim Success Rate (%)
SELECT ROUND(
       COUNT(*) * 100.0 /
       (SELECT COUNT(*) FROM claims_data),
       2
       ) AS success_rate
FROM claims_data
WHERE status = 'Completed';

-- KPI 10: Top Provider City
SELECT city,
       COUNT(*) AS provider_count
FROM providers_data
GROUP BY city
ORDER BY provider_count DESC
LIMIT 1;

-- KPI 11: Top Receiver City
SELECT city,
       COUNT(*) AS receiver_count
FROM receivers_data
GROUP BY city
ORDER BY receiver_count DESC
LIMIT 1;

-- KPI 12: Most Common Food Type
SELECT food_type,
       COUNT(*) AS total_listings
FROM food_listings_data
GROUP BY food_type
ORDER BY total_listings DESC
LIMIT 1;

-- KPI 13: Most Common Meal Type
SELECT meal_type,
       COUNT(*) AS total_listings
FROM food_listings_data
GROUP BY meal_type
ORDER BY total_listings DESC
LIMIT 1;

-- KPI 14: Average Food Quantity per Listing
SELECT ROUND(AVG(quantity),2) AS avg_food_quantity
FROM food_listings_data;

-- KPI 15: Average Quantity Claimed per Receiver
SELECT ROUND(AVG(total_claimed),2) AS avg_quantity_claimed
FROM
(
    SELECT c.receiver_id,
           SUM(f.quantity) AS total_claimed
    FROM claims_data c
    JOIN food_listings_data f
    ON c.food_id = f.food_id
    GROUP BY c.receiver_id
) t;