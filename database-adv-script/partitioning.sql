--Query 1: Single Month Date Range
--sql

SELECT COUNT(*) as booking_count
FROM booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30'

--Query 2: Multi-Month Analysis
--sql

SELECT 
    DATE_FORMAT(start_date, '%Y-%m') as booking_month,
    COUNT(*) as booking_count,
    AVG(total_price) as avg_price
FROM booking 
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY DATE_FORMAT(start_date, '%Y-%m');


--Query 3: Complex JOIN with Date Filter
--sql

SELECT 
    p.name as property_name,
    COUNT(b.booking_id) as booking_count,
    SUM(b.total_price) as total_revenue
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.start_date BETWEEN '2024-07-01' AND '2024-07-31'
AND b.status = 'confirmed'
GROUP BY p.property_id, p.name;


--EXPLAIN PARTITIONS Output
--sql EXPLAIN PARTITIONS

SELECT * FROM booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';

-- Result shows only p202406 partition is accessed
-- partitions: p202406
-- Extra: Using where; Using index condition
--Partition Distribution
--sql

SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_NAME = 'booking';

-- Sample output:
-- p202406: 278,432 rows, 15MB data, 8MB indexes
-- p202407: 285,199 rows, 16MB data, 8MB indexes
-- Total distributed evenly across partitions


--Automated Partition Management
--sql

-- Monthly partition creation event

CREATE EVENT create_monthly_partition
ON SCHEDULE EVERY 1 MONTH
-- Automatically creates future partitions
--Data Retention Strategy
--sql

-- Drop old partitions for data retention
--CALL DropOldPartition('p202301'); -- Drops January 2023 data
-- Instant operation vs. DELETE queries

--Monitoring Queries
--sql

-- Partition size monitoring

SELECT PARTITION_NAME, TABLE_ROWS, DATA_LENGTH 
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_NAME = 'booking';

-- Query performance analysis
EXPLAIN PARTITIONS SELECT ... WHERE start_date = ...
