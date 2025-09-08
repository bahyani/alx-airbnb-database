SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    u.email
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id;

-- LEFT JOIN: All properties and their reviews (including properties with no reviews)
SELECT 
    p.property_id,
    p.name,
    p.price_per_night,
    r.review_id,
    r.rating,
    r.comment
FROM property p
LEFT JOIN review r ON p.property_id = r.property_id;

-- FULL OUTER JOIN: All users and all bookings (MySQL doesn't support FULL OUTER JOIN, so using UNION)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.total_price
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.total_price
FROM user u
RIGHT JOIN booking b ON u.user_id = b.user_id;
