-- =====================================================
-- Database Index Creation for Performance Optimization
-- Property Booking System
-- =====================================================

-- =====================================================
-- PERFORMANCE MEASUREMENT - BEFORE INDEXES
-- =====================================================

-- Test Query 1: Property search (BEFORE indexes)
EXPLAIN SELECT * FROM property p 
WHERE p.is_active = TRUE 
AND p.is_available = TRUE 
AND p.price_per_night BETWEEN 100 AND 300;

-- Test Query 2: Booking availability check (BEFORE indexes)
EXPLAIN SELECT * FROM booking 
WHERE property_id = 'test-property-id' 
AND start_date <= '2024-12-01' 
AND end_date >= '2024-11-25' 
AND status IN ('confirmed', 'checked_in');

-- Test Query 3: User booking history (BEFORE indexes)
EXPLAIN SELECT b.*, p.name 
FROM booking b 
JOIN property p ON b.property_id = p.property_id 
WHERE b.user_id = 'test-user-id' 
ORDER BY b.created_at DESC;

-- =====================================================
-- INDEX CREATION
-- =====================================================

-- USER TABLE INDEXES
CREATE INDEX idx_user_email_lookup ON user(email);
CREATE INDEX idx_user_status ON user(is_active, is_verified);
CREATE INDEX idx_user_fullname ON user(first_name, last_name);
CREATE INDEX idx_user_role_filter ON user(role_id);

-- BOOKING TABLE INDEXES
CREATE INDEX idx_booking_user ON booking(user_id);
CREATE INDEX idx_booking_property ON booking(property_id);
CREATE INDEX idx_booking_dates ON booking(start_date, end_date);
CREATE INDEX idx_booking_status ON booking(status);
CREATE INDEX idx_booking_property_dates ON booking(property_id, start_date, end_date, status);
CREATE INDEX idx_booking_created ON booking(created_at);

-- PROPERTY TABLE INDEXES
CREATE INDEX idx_property_host ON property(host_id);
CREATE INDEX idx_property_location ON property(location_id);
CREATE INDEX idx_property_price ON property(price_per_night);
CREATE INDEX idx_property_availability ON property(is_active, is_available);
CREATE INDEX idx_property_search ON property(location_id, is_active, is_available, price_per_night);
CREATE INDEX idx_property_guests ON property(max_guests);
CREATE INDEX idx_property_type ON property(property_type);

-- ADDITIONAL INDEXES
CREATE INDEX idx_review_property ON review(property_id);
CREATE INDEX idx_review_user ON review(user_id);
CREATE INDEX idx_review_rating ON review(rating);
CREATE INDEX idx_payment_booking ON payment(booking_id);
CREATE INDEX idx_payment_status ON payment(payment_status);

-- =====================================================
-- PERFORMANCE MEASUREMENT - AFTER INDEXES
-- =====================================================

-- Test Query 1: Property search (AFTER indexes)
EXPLAIN SELECT * FROM property p 
WHERE p.is_active = TRUE 
AND p.is_available = TRUE 
AND p.price_per_night BETWEEN 100 AND 300;

-- Test Query 2: Booking availability check (AFTER indexes)
EXPLAIN SELECT * FROM booking 
WHERE property_id = 'test-property-id' 
AND start_date <= '2024-12-01' 
AND end_date >= '2024-11-25' 
AND status IN ('confirmed', 'checked_in');

-- Test Query 3: User booking history (AFTER indexes)
EXPLAIN SELECT b.*, p.name 
FROM booking b 
JOIN property p ON b.property_id = p.property_id 
WHERE b.user_id = 'test-user-id' 
ORDER BY b.created_at DESC;

-- =====================================================
-- DETAILED PERFORMANCE ANALYSIS
-- =====================================================

-- Enable query profiling for detailed analysis
SET profiling = 1;

-- Run performance test queries
SELECT * FROM property p 
WHERE p.is_active = TRUE 
AND p.is_available = TRUE 
AND p.price_per_night BETWEEN 100 AND 300;

SELECT * FROM booking 
WHERE property_id = 'test-property-id' 
AND start_date <= '2024-12-01' 
AND end_date >= '2024-11-25' 
AND status IN ('confirmed', 'checked_in');

SELECT b.*, p.name 
FROM booking b 
JOIN property p ON b.property_id = p.property_id 
WHERE b.user_id = 'test-user-id' 
ORDER BY b.created_at DESC LIMIT 10;

-- View profiling results
SHOW PROFILES;

-- Get detailed profile for specific queries (replace X with query ID from SHOW PROFILES)
-- SHOW PROFILE FOR QUERY 1;
-- SHOW PROFILE FOR QUERY 2;
-- SHOW PROFILE FOR QUERY 3;

-- =====================================================
-- INDEX USAGE ANALYSIS
-- =====================================================

-- Check index statistics
SHOW INDEX FROM user;
SHOW INDEX FROM booking;
SHOW INDEX FROM property;

-- Analyze table statistics after index creation
ANALYZE TABLE user;
ANALYZE TABLE booking;
ANALYZE TABLE property;

-- Check index cardinality and selectivity
SELECT 
    table_name,
    index_name,
    column_name,
    cardinality,
    CASE 
        WHEN cardinality = 0 THEN 'No data'
        ELSE CONCAT(ROUND(cardinality/
            (SELECT table_rows FROM information_schema.tables 
             WHERE table_name = s.table_name AND table_schema = DATABASE())*100, 2), '%')
    END AS selectivity
FROM information_schema.statistics s
WHERE table_schema = DATABASE()
AND table_name IN ('user', 'booking', 'property')
ORDER BY table_name, index_name;