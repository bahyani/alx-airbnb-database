-- =====================================================
-- TASK 5: Table Partitioning Implementation
-- Booking Table Partitioning by start_date
-- =====================================================

-- =====================================================
-- BACKUP EXISTING BOOKING TABLE
-- =====================================================

-- Create backup of existing booking table
CREATE TABLE booking_backup AS SELECT * FROM booking;

-- =====================================================
-- DROP EXISTING BOOKING TABLE
-- =====================================================

-- Drop foreign key constraints that reference booking table
ALTER TABLE payment DROP FOREIGN KEY fk_payment_booking;
ALTER TABLE review DROP FOREIGN KEY fk_review_booking;
ALTER TABLE message DROP FOREIGN KEY fk_message_booking;

-- Drop the existing booking table
DROP TABLE booking;

-- =====================================================
-- CREATE PARTITIONED BOOKING TABLE
-- =====================================================

-- Create new partitioned booking table
CREATE TABLE booking (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    guest_count INTEGER NOT NULL DEFAULT 1,
    status ENUM('pending', 'confirmed', 'checked_in', 'checked_out', 'canceled', 'refunded') NOT NULL DEFAULT 'pending',
    special_requests TEXT,
    cancellation_reason TEXT,
    canceled_at TIMESTAMP NULL,
    confirmed_at TIMESTAMP NULL,
    checked_in_at TIMESTAMP NULL,
    checked_out_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Primary key must include partition key
    PRIMARY KEY (booking_id, start_date),
    
    -- Check constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_booking_price CHECK (total_price > 0),
    CONSTRAINT chk_booking_guests CHECK (guest_count > 0),
    
    -- Indexes for performance
    INDEX idx_booking_property_date (property_id, start_date),
    INDEX idx_booking_user_date (user_id, start_date),
    INDEX idx_booking_status_date (status, start_date),
    INDEX idx_booking_created (created_at)
)
-- Range partitioning by start_date (monthly partitions)
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    -- Historical partitions (2023)
    PARTITION p202301 VALUES LESS THAN (202302),
    PARTITION p202302 VALUES LESS THAN (202303),
    PARTITION p202303 VALUES LESS THAN (202304),
    PARTITION p202304 VALUES LESS THAN (202305),
    PARTITION p202305 VALUES LESS THAN (202306),
    PARTITION p202306 VALUES LESS THAN (202307),
    PARTITION p202307 VALUES LESS THAN (202308),
    PARTITION p202308 VALUES LESS THAN (202309),
    PARTITION p202309 VALUES LESS THAN (202310),
    PARTITION p202310 VALUES LESS THAN (202311),
    PARTITION p202311 VALUES LESS THAN (202312),
    PARTITION p202312 VALUES LESS THAN (202401),
    
    -- Current year partitions (2024)
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION p202404 VALUES LESS THAN (202405),
    PARTITION p202405 VALUES LESS THAN (202406),
    PARTITION p202406 VALUES LESS THAN (202407),
    PARTITION p202407 VALUES LESS THAN (202408),
    PARTITION p202408 VALUES LESS THAN (202409),
    PARTITION p202409 VALUES LESS THAN (202410),
    PARTITION p202410 VALUES LESS THAN (202411),
    PARTITION p202411 VALUES LESS THAN (202412),
    PARTITION p202412 VALUES LESS THAN (202501),
    
    -- Future year partitions (2025)
    PARTITION p202501 VALUES LESS THAN (202502),
    PARTITION p202502 VALUES LESS THAN (202503),
    PARTITION p202503 VALUES LESS THAN (202504),
    PARTITION p202504 VALUES LESS THAN (202505),
    PARTITION p202505 VALUES LESS THAN (202506),
    PARTITION p202506 VALUES LESS THAN (202507),
    PARTITION p202507 VALUES LESS THAN (202508),
    PARTITION p202508 VALUES LESS THAN (202509),
    PARTITION p202509 VALUES LESS THAN (202510),
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
    
    -- Default partition for future data
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- =====================================================
-- RESTORE DATA FROM BACKUP
-- =====================================================

-- Insert data back into partitioned table
INSERT INTO booking SELECT * FROM booking_backup;

-- =====================================================
-- RECREATE FOREIGN KEY CONSTRAINTS
-- =====================================================

-- Add foreign key constraints back
ALTER TABLE booking 
ADD CONSTRAINT fk_booking_property 
FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE;

ALTER TABLE booking 
ADD CONSTRAINT fk_booking_user 
FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE;

-- Recreate foreign keys from other tables to booking
ALTER TABLE payment 
ADD CONSTRAINT fk_payment_booking 
FOREIGN KEY (booking_id, start_date) REFERENCES booking(booking_id, start_date) ON DELETE CASCADE;

ALTER TABLE review 
ADD CONSTRAINT fk_review_booking 
FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE SET NULL;

ALTER TABLE message 
ADD CONSTRAINT fk_message_booking 
FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE SET NULL;

-- =====================================================
-- PARTITION MANAGEMENT PROCEDURES
-- =====================================================

-- Procedure to add new monthly partitions
DELIMITER //
CREATE PROCEDURE AddMonthlyPartition(IN partition_year INT, IN partition_month INT)
BEGIN
    DECLARE partition_name VARCHAR(10);
    DECLARE partition_value INT;
    DECLARE next_partition_value INT;
    DECLARE sql_statement TEXT;
    
    -- Calculate partition values
    SET partition_value = partition_year * 100 + partition_month;
    SET next_partition_value = IF(partition_month = 12, 
                                  (partition_year + 1) * 100 + 1, 
                                  partition_year * 100 + partition_month + 1);
    
    -- Create partition name
    SET partition_name = CONCAT('p', LPAD(partition_value, 6, '0'));
    
    -- Build ALTER TABLE statement
    SET sql_statement = CONCAT(
        'ALTER TABLE booking REORGANIZE PARTITION p_future INTO (',
        'PARTITION ', partition_name, ' VALUES LESS THAN (', next_partition_value, '),',
        'PARTITION p_future VALUES LESS THAN MAXVALUE',
        ')'
    );
    
    -- Execute the statement
    SET @sql = sql_statement;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Partition ', partition_name, ' created successfully') AS result;
END //
DELIMITER ;

-- Procedure to drop old partitions (for data retention)
DELIMITER //
CREATE PROCEDURE DropOldPartition(IN partition_name VARCHAR(10))
BEGIN
    DECLARE sql_statement TEXT;
    
    -- Build ALTER TABLE statement to drop partition
    SET sql_statement = CONCAT('ALTER TABLE booking DROP PARTITION ', partition_name);
    
    -- Execute the statement
    SET @sql = sql_statement;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Partition ', partition_name, ' dropped successfully') AS result;
END //
DELIMITER ;

-- =====================================================
-- PERFORMANCE TEST QUERIES
-- =====================================================

-- Query 1: Date range query (should use partition pruning)
SELECT COUNT(*) as booking_count
FROM booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';

-- Query 2: Multi-month date range query
SELECT 
    DATE_FORMAT(start_date, '%Y-%m') as booking_month,
    COUNT(*) as booking_count,
    AVG(total_price) as avg_price
FROM booking 
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY booking_month;

-- Query 3: Property bookings by date range
SELECT 
    p.name as property_name,
    COUNT(b.booking_id) as booking_count,
    SUM(b.total_price) as total_revenue
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.start_date BETWEEN '2024-07-01' AND '2024-07-31'
AND b.status = 'confirmed'
GROUP BY p.property_id, p.name
ORDER BY total_revenue DESC;

-- =====================================================
-- PARTITION INFORMATION QUERIES
-- =====================================================

-- View partition information
SELECT 
    PARTITION_NAME,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'booking'
AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_ORDINAL_POSITION;

-- Check partition pruning in query execution
EXPLAIN PARTITIONS
SELECT * FROM booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';

-- =====================================================
-- AUTOMATED PARTITION MAINTENANCE
-- =====================================================

-- Event to automatically create next month's partition
DELIMITER //
CREATE EVENT create_monthly_partition
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-01-01 00:00:00'
DO BEGIN
    DECLARE next_month INT;
    DECLARE next_year INT;
    
    SET next_month = MONTH(DATE_ADD(NOW(), INTERVAL 2 MONTH));
    SET next_year = YEAR(DATE_ADD(NOW(), INTERVAL 2 MONTH));
    
    CALL AddMonthlyPartition(next_year, next_month);
END //
DELIMITER ;

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- =====================================================
-- CLEANUP
-- =====================================================

-- Drop backup table after verification
-- DROP TABLE booking_backup;