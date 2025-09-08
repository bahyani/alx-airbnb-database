-- Query 1: Properties with average rating greater than 4.0 using subquery
SELECT 
    property_id,
    name,
    price_per_night
FROM property
WHERE property_id IN (
    SELECT property_id
    FROM review
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
);

-- Query 2: Correlated subquery to find users with more than 3 bookings
SELECT 
    user_id,
    first_name,
    last_name,
    email
FROM user u
WHERE (
    SELECT COUNT(*)
    FROM booking b
    WHERE b.user_id = u.user_id
) > 3;
