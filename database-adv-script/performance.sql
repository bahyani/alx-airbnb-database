-- =====================================================
-- TASK 4: Query Performance Optimization
-- Property Booking System - Performance Analysis
-- =====================================================

-- =====================================================
-- INITIAL QUERY (Before Optimization)
-- =====================================================

-- Initial query retrieving all bookings with user, property, and payment details
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.guest_count,
    b.status AS booking_status,
    b.special_requests,
    b.created_at AS booking_date,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.is_verified,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.price_per_night,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    p.property_type,
    
    -- Location details
    l.city,
    l.state_province,
    l.country,
    l.street_address,
    
    -- Host details
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.currency,
    pay.payment_status,
    pay.payment_type,
    pay.payment_date,
    
    -- Payment method details
    pm.method_name AS payment_method

FROM booking b
LEFT JOIN user u ON b.user_id = u.user_id
LEFT JOIN property p ON b.property_id = p.property_id
LEFT JOIN location l ON p.location_id = l.location_id
LEFT JOIN user h ON p.host_id = h.user_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
LEFT JOIN payment_method pm ON pay.payment_method_id = pm.payment_method_id

ORDER BY b.created_at DESC;

-- =====================================================
-- PERFORMANCE ANALYSIS - INITIAL QUERY
-- =====================================================

-- Analyze the initial query performance
EXPLAIN FORMAT=JSON
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.guest_count,
    b.status AS booking_status,
    b.special_requests,
    b.created_at AS booking_date,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.is_verified,
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.price_per_night,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    p.property_type,
    l.city,
    l.state_province,
    l.country,
    l.street_address,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.currency,
    pay.payment_status,
    pay.payment_type,
    pay.payment_date,
    pm.method_name AS payment_method
FROM booking b
LEFT JOIN user u ON b.user_id = u.user_id
LEFT JOIN property p ON b.property_id = p.property_id
LEFT JOIN location l ON p.location_id = l.location_id
LEFT JOIN user h ON p.host_id = h.user_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
LEFT JOIN payment_method pm ON pay.payment_method_id = pm.payment_method_id
ORDER BY b.created_at DESC;

-- =====================================================
-- IDENTIFIED INEFFICIENCIES
-- =====================================================

/*
PERFORMANCE ISSUES IDENTIFIED:

1. Multiple LEFT JOINs causing Cartesian product effect
2. No LIMIT clause - retrieving all records unnecessarily
3. Fetching too many columns including large TEXT fields (description)
4. No WHERE clause filtering - processing entire dataset
5. ORDER BY on non-indexed column (created_at)
6. Multiple joins to user table (guest and host)
7. Payment details may have multiple records per booking

OPTIMIZATION STRATEGIES:
1. Add appropriate indexes
2. Limit result set with pagination
3. Remove unnecessary columns
4. Add filtering conditions
5. Optimize JOIN order
6. Use subqueries for optional data
*/

-- =====================================================
-- REFACTORED QUERY (After Optimization)
-- =====================================================

-- Optimized query with performance improvements
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.guest_count,
    b.status AS booking_status,
    b.created_at AS booking_date,
    
    -- User details (essential only)
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    u.is_verified,
    
    -- Property details (essential only)
    p.name AS property_name,
    p.price_per_night,
    p.max_guests,
    p.property_type,
    
    -- Location (city and country only)
    l.city,
    l.country,
    
    -- Host name only
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    
    -- Payment summary (latest payment only)
    (SELECT pay.payment_status 
     FROM payment pay 
     WHERE pay.booking_id = b.booking_id 
     ORDER BY pay.payment_date DESC 
     LIMIT 1) AS latest_payment_status,
    
    (SELECT pay.amount 
     FROM payment pay 
     WHERE pay.booking_id = b.booking_id 
     ORDER BY pay.payment_date DESC 
     LIMIT 1) AS latest_payment_amount

FROM booking b
INNER JOIN user u ON b.user_id = u.user_id AND u.is_active = TRUE
INNER JOIN property p ON b.property_id = p.property_id AND p.is_active = TRUE
INNER JOIN location l ON p.location_id = l.location_id
INNER JOIN user h ON p.host_id = h.user_id AND h.is_active = TRUE

WHERE b.status IN ('confirmed', 'checked_in', 'checked_out')
AND b.created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)

ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- PERFORMANCE ANALYSIS - REFACTORED QUERY
-- =====================================================

-- Analyze the refactored query performance
EXPLAIN FORMAT=JSON
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.guest_count,
    b.status AS booking_status,
    b.created_at AS booking_date,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    u.is_verified,
    p.name AS property_name,
    p.price_per_night,
    p.max_guests,
    p.property_type,
    l.city,
    l.country,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    (SELECT pay.payment_status 
     FROM payment pay 
     WHERE pay.booking_id = b.booking_id 
     ORDER BY pay.payment_date DESC 
     LIMIT 1) AS latest_payment_status,
    (SELECT pay.amount 
     FROM payment pay 
     WHERE pay.booking_id = b.booking_id 
     ORDER BY pay.payment_date DESC 
     LIMIT 1) AS latest_payment_amount
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id AND u.is_active = TRUE
INNER JOIN property p ON b.property_id = p.property_id AND p.is_active = TRUE
INNER JOIN location l ON p.location_id = l.location_id
INNER JOIN user h ON p.host_id = h.user_id AND h.is_active = TRUE
WHERE b.status IN ('confirmed', 'checked_in', 'checked_out')
AND b.created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- ALTERNATIVE OPTIMIZED QUERY (Using CTEs)
-- =====================================================

-- Alternative approach using Common Table Expressions for better readability
WITH recent_bookings AS (
    SELECT booking_id, user_id, property_id, start_date, end_date, 
           total_price, guest_count, status, created_at
    FROM booking
    WHERE status IN ('confirmed', 'checked_in', 'checked_out')
    AND created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
    ORDER BY created_at DESC
    LIMIT 100
),
latest_payments AS (
    SELECT DISTINCT
        p1.booking_id,
        p1.payment_status,
        p1.amount,
        p1.payment_date
    FROM payment p1
    INNER JOIN (
        SELECT booking_id, MAX(payment_date) as max_date
        FROM payment
        GROUP BY booking_id
    ) p2 ON p1.booking_id = p2.booking_id AND p1.payment_date = p2.max_date
)

SELECT 
    rb.booking_id,
    rb.start_date,
    rb.end_date,
    rb.total_price,
    rb.guest_count,
    rb.status AS booking_status,
    rb.created_at AS booking_date,
    
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    
    p.name AS property_name,
    p.price_per_night,
    p.property_type,
    
    l.city,
    l.country,
    
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    
    lp.payment_status,
    lp.amount AS payment_amount

FROM recent_bookings rb
INNER JOIN user u ON rb.user_id = u.user_id
INNER JOIN property p ON rb.property_id = p.property_id
INNER JOIN location l ON p.location_id = l.location_id
INNER JOIN user h ON p.host_id = h.user_id
LEFT JOIN latest_payments lp ON rb.booking_id = lp.booking_id

ORDER BY rb.created_at DESC;

-- =====================================================
-- PERFORMANCE COMPARISON QUERIES
-- =====================================================

-- Enable query profiling for performance comparison
SET profiling = 1;

-- Run the initial query (comment out for large datasets)
-- [Initial query would go here]

-- Run the optimized query
-- [Optimized query would go here]

-- Check profiling results
SHOW PROFILES;

-- =====================================================
-- REQUIRED INDEXES for OPTIMAL PERFORMANCE
-- =====================================================

-- Indexes specifically needed for these queries
CREATE INDEX IF NOT EXISTS idx_booking_status_created ON booking(status, created_at);
CREATE INDEX IF NOT EXISTS idx_booking_user_active ON booking(user_id) WHERE user_id IN (SELECT user_id FROM user WHERE is_active = TRUE);
CREATE INDEX IF NOT EXISTS idx_property_active ON property(is_active, property_id);
CREATE INDEX IF NOT EXISTS idx_user_active ON user(is_active, user_id);
CREATE INDEX IF NOT EXISTS idx_payment_booking_date ON payment(booking_id, payment_date);

-- =====================================================
-- PERFORMANCE METRICS ANALYSIS
-- =====================================================

/*
EXPECTED PERFORMANCE IMPROVEMENTS:

1. EXECUTION TIME:
   - Initial Query: ~2000-5000ms (large datasets)
   - Optimized Query: ~100-300ms (80-90% improvement)

2. MEMORY USAGE:
   - Reduced result set size with LIMIT
   - Fewer columns transferred over network
   - Eliminated unnecessary Cartesian products

3. I/O OPERATIONS:
   - Reduced table scans with proper indexing
   - Filtered data early with WHERE conditions
   - Used subqueries to avoid multiple JOINs for payment data

4. SCALABILITY:
   - Query performance remains stable as data grows
   - Pagination support with LIMIT/OFFSET
   - Efficient for web application use cases

OPTIMIZATION TECHNIQUES APPLIED:
✓ Changed LEFT JOIN to INNER JOIN where appropriate
✓ Added filtering conditions (WHERE clause)
✓ Limited result set with LIMIT clause
✓ Reduced number of columns selected
✓ Used subqueries for optional/complex data
✓ Added proper indexes
✓ Eliminated redundant joins
✓ Used CONCAT for computed fields
*/
