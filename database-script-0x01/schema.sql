-- =====================================================
-- Property Booking System - Database Schema
-- Version: 1.0
-- Description: Complete SQL schema with normalized tables
-- =====================================================

-- Drop existing tables in reverse dependency order (if they exist)
DROP TABLE IF EXISTS property_amenity;
DROP TABLE IF EXISTS amenity;
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS property;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS payment_method;
DROP TABLE IF EXISTS role;

-- =====================================================
-- REFERENCE TABLES (Independent entities)
-- =====================================================

-- Role table for user roles and permissions
CREATE TABLE role (
    role_id CHAR(36) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_role_name (role_name),
    INDEX idx_role_active (is_active)
);

-- Payment method reference table
CREATE TABLE payment_method (
    payment_method_id CHAR(36) PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    processing_fee_percentage DECIMAL(5,4) DEFAULT 0.0000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_processing_fee CHECK (processing_fee_percentage >= 0 AND processing_fee_percentage <= 1),
    
    -- Indexes
    INDEX idx_payment_method_name (method_name),
    INDEX idx_payment_method_active (is_active)
);

-- Location table for normalized address data
CREATE TABLE location (
    location_id CHAR(36) PRIMARY KEY,
    street_address VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_longitude CHECK (longitude BETWEEN -180 AND 180),
    
    -- Indexes
    INDEX idx_location_city (city),
    INDEX idx_location_state (state_province),
    INDEX idx_location_country (country),
    INDEX idx_location_postal_code (postal_code),
    INDEX idx_location_coordinates (latitude, longitude),
    INDEX idx_location_city_country (city, country)
);

-- Amenity reference table
CREATE TABLE amenity (
    amenity_id CHAR(36) PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(50),
    icon_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_amenity_name (amenity_name),
    INDEX idx_amenity_category (category),
    INDEX idx_amenity_active (is_active)
);

-- =====================================================
-- MAIN ENTITY TABLES
-- =====================================================

-- User table with enhanced normalization
CREATE TABLE user (
    user_id CHAR(36) PRIMARY KEY,
    role_id CHAR(36) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    profile_picture_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES role(role_id) ON DELETE RESTRICT,
    
    -- Check constraints
    CONSTRAINT chk_user_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_user_phone_format CHECK (phone_number IS NULL OR phone_number REGEXP '^\\+?[1-9]\\d{1,14}$'),
    CONSTRAINT chk_user_birth_date CHECK (date_of_birth IS NULL OR date_of_birth <= CURDATE()),
    
    -- Indexes
    INDEX idx_user_email (email),
    INDEX idx_user_role (role_id),
    INDEX idx_user_name (first_name, last_name),
    INDEX idx_user_active (is_active),
    INDEX idx_user_verified (is_verified),
    INDEX idx_user_created (created_at)
);

-- Property table with enhanced normalization
CREATE TABLE property (
    property_id CHAR(36) PRIMARY KEY,
    host_id CHAR(36) NOT NULL,
    location_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    max_guests INTEGER NOT NULL DEFAULT 1,
    bedrooms INTEGER DEFAULT 0,
    bathrooms DECIMAL(3,1) DEFAULT 0,
    property_type VARCHAR(50),
    total_area_sqft INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    is_available BOOLEAN DEFAULT TRUE,
    minimum_stay_nights INTEGER DEFAULT 1,
    maximum_stay_nights INTEGER DEFAULT 365,
    check_in_time TIME DEFAULT '15:00:00',
    check_out_time TIME DEFAULT '11:00:00',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_property_host FOREIGN KEY (host_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_property_location FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE RESTRICT,
    
    -- Check constraints
    CONSTRAINT chk_property_price CHECK (price_per_night > 0),
    CONSTRAINT chk_property_guests CHECK (max_guests > 0 AND max_guests <= 50),
    CONSTRAINT chk_property_bedrooms CHECK (bedrooms >= 0),
    CONSTRAINT chk_property_bathrooms CHECK (bathrooms >= 0),
    CONSTRAINT chk_property_area CHECK (total_area_sqft IS NULL OR total_area_sqft > 0),
    CONSTRAINT chk_property_stay_nights CHECK (minimum_stay_nights > 0 AND maximum_stay_nights >= minimum_stay_nights),
    
    -- Indexes
    INDEX idx_property_host (host_id),
    INDEX idx_property_location (location_id),
    INDEX idx_property_price (price_per_night),
    INDEX idx_property_guests (max_guests),
    INDEX idx_property_type (property_type),
    INDEX idx_property_active (is_active),
    INDEX idx_property_available (is_available),
    INDEX idx_property_created (created_at),
    INDEX idx_property_price_guests (price_per_night, max_guests)
);

-- =====================================================
-- TRANSACTION TABLES
-- =====================================================

-- Booking table
CREATE TABLE booking (
    booking_id CHAR(36) PRIMARY KEY,
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
    
    -- Foreign key constraints
    CONSTRAINT fk_booking_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    
    -- Check constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_booking_price CHECK (total_price > 0),
    CONSTRAINT chk_booking_guests CHECK (guest_count > 0),
    
    -- Indexes
    INDEX idx_booking_property (property_id),
    INDEX idx_booking_user (user_id),
    INDEX idx_booking_dates (start_date, end_date),
    INDEX idx_booking_status (status),
    INDEX idx_booking_created (created_at),
    INDEX idx_booking_property_dates (property_id, start_date, end_date),
    INDEX idx_booking_user_status (user_id, status)
);

-- Payment table with enhanced tracking
CREATE TABLE payment (
    payment_id CHAR(36) PRIMARY KEY,
    booking_id CHAR(36) NOT NULL,
    payment_method_id CHAR(36) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    transaction_id VARCHAR(255) UNIQUE,
    payment_status ENUM('pending', 'processing', 'completed', 'failed', 'canceled', 'refunded', 'partially_refunded') NOT NULL DEFAULT 'pending',
    payment_type ENUM('full_payment', 'deposit', 'remaining_balance', 'security_deposit', 'refund') DEFAULT 'full_payment',
    processing_fee DECIMAL(8,2) DEFAULT 0.00,
    net_amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    failure_reason TEXT,
    refund_amount DECIMAL(10,2) DEFAULT 0.00,
    refunded_at TIMESTAMP NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_method(payment_method_id) ON DELETE RESTRICT,
    
    -- Check constraints
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT chk_payment_processing_fee CHECK (processing_fee >= 0),
    CONSTRAINT chk_payment_net_amount CHECK (net_amount >= 0),
    CONSTRAINT chk_payment_refund_amount CHECK (refund_amount >= 0 AND refund_amount <= amount),
    
    -- Indexes
    INDEX idx_payment_booking (booking_id),
    INDEX idx_payment_method (payment_method_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_type (payment_type),
    INDEX idx_payment_transaction_id (transaction_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_processed (processed_at)
);

-- =====================================================
-- INTERACTION TABLES
-- =====================================================

-- Review table with enhanced features
CREATE TABLE review (
    review_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    booking_id CHAR(36),
    rating INTEGER NOT NULL,
    title VARCHAR(200),
    comment TEXT NOT NULL,
    cleanliness_rating INTEGER,
    communication_rating INTEGER,
    location_rating INTEGER,
    value_rating INTEGER,
    is_visible BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    host_response TEXT,
    host_response_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_review_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE SET NULL,
    
    -- Check constraints
    CONSTRAINT chk_review_rating CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_review_cleanliness CHECK (cleanliness_rating IS NULL OR (cleanliness_rating >= 1 AND cleanliness_rating <= 5)),
    CONSTRAINT chk_review_communication CHECK (communication_rating IS NULL OR (communication_rating >= 1 AND communication_rating <= 5)),
    CONSTRAINT chk_review_location CHECK (location_rating IS NULL OR (location_rating >= 1 AND location_rating <= 5)),
    CONSTRAINT chk_review_value CHECK (value_rating IS NULL OR (value_rating >= 1 AND value_rating <= 5)),
    
    -- Unique constraint to prevent duplicate reviews
    UNIQUE KEY unique_user_property_review (user_id, property_id, booking_id),
    
    -- Indexes
    INDEX idx_review_property (property_id),
    INDEX idx_review_user (user_id),
    INDEX idx_review_booking (booking_id),
    INDEX idx_review_rating (rating),
    INDEX idx_review_visible (is_visible),
    INDEX idx_review_verified (is_verified),
    INDEX idx_review_created (created_at),
    INDEX idx_review_property_rating (property_id, rating)
);

-- Message table for user communication
CREATE TABLE message (
    message_id CHAR(36) PRIMARY KEY,
    sender_id CHAR(36) NOT NULL,
    recipient_id CHAR(36) NOT NULL,
    booking_id CHAR(36),
    subject VARCHAR(255),
    message_body TEXT NOT NULL,
    message_type ENUM('inquiry', 'booking_related', 'support', 'general') DEFAULT 'general',
    is_read BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    parent_message_id CHAR(36),
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    -- Foreign key constraints
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_message_recipient FOREIGN KEY (recipient_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_message_booking FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE SET NULL,
    CONSTRAINT fk_message_parent FOREIGN KEY (parent_message_id) REFERENCES message(message_id) ON DELETE SET NULL,
    
    -- Check constraint to prevent self-messaging
    CONSTRAINT chk_message_different_users CHECK (sender_id != recipient_id),
    
    -- Indexes
    INDEX idx_message_sender (sender_id),
    INDEX idx_message_recipient (recipient_id),
    INDEX idx_message_booking (booking_id),
    INDEX idx_message_type (message_type),
    INDEX idx_message_read (is_read),
    INDEX idx_message_archived (is_archived),
    INDEX idx_message_sent (sent_at),
    INDEX idx_message_conversation (sender_id, recipient_id, sent_at),
    INDEX idx_message_parent (parent_message_id)
);

-- =====================================================
-- JUNCTION TABLES (Many-to-Many relationships)
-- =====================================================

-- Property amenities junction table
CREATE TABLE property_amenity (
    property_amenity_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    amenity_id CHAR(36) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_property_amenity_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_property_amenity_amenity FOREIGN KEY (amenity_id) REFERENCES amenity(amenity_id) ON DELETE CASCADE,
    
    -- Unique constraint to prevent duplicate amenities for same property
    UNIQUE KEY unique_property_amenity (property_id, amenity_id),
    
    -- Indexes
    INDEX idx_property_amenity_property (property_id),
    INDEX idx_property_amenity_amenity (amenity_id),
    INDEX idx_property_amenity_available (is_available)
);

-- =====================================================
-- ADDITIONAL PERFORMANCE INDEXES
-- =====================================================

-- Composite indexes for common query patterns
CREATE INDEX idx_booking_availability_check ON booking (property_id, status, start_date, end_date);
CREATE INDEX idx_property_search ON property (location_id, is_active, is_available, price_per_night);
CREATE INDEX idx_user_host_properties ON property (host_id, is_active, created_at);
CREATE INDEX idx_payment_financial_reports ON payment (payment_status, payment_date, amount);
CREATE INDEX idx_review_property_stats ON review (property_id, is_visible, rating, created_at);

-- =====================================================
-- INSERT INITIAL DATA
-- =====================================================

-- Insert default roles
INSERT INTO role (role_id, role_name, description, permissions) VALUES 
(UUID(), 'guest', 'Regular user who can book properties', '["book_property", "write_review", "send_message"]'),
(UUID(), 'host', 'User who can list and manage properties', '["book_property", "list_property", "manage_property", "write_review", "send_message", "respond_review"]'),
(UUID(), 'admin', 'System administrator with full access', '["*"]');

-- Insert default payment methods
INSERT INTO payment_method (payment_method_id, method_name, description, processing_fee_percentage) VALUES 
(UUID(), 'Credit Card', 'Visa, MasterCard, American Express, Discover', 0.029),
(UUID(), 'PayPal', 'PayPal account payment', 0.034),
(UUID(), 'Stripe', 'Stripe payment processing', 0.029),
(UUID(), 'Bank Transfer', 'Direct bank account transfer', 0.008);

-- Insert common amenities
INSERT INTO amenity (amenity_id, amenity_name, category, description) VALUES 
(UUID(), 'WiFi', 'Technology', 'Free wireless internet access'),
(UUID(), 'Air Conditioning', 'Climate', 'Air conditioning throughout property'),
(UUID(), 'Kitchen', 'Facilities', 'Full kitchen with cooking facilities'),
(UUID(), 'Parking', 'Transportation', 'Free on-site parking'),
(UUID(), 'Pool', 'Recreation', 'Swimming pool access'),
(UUID(), 'Gym', 'Recreation', 'Fitness center or gym access'),
(UUID(), 'Pet Friendly', 'Policies', 'Pets allowed with restrictions'),
(UUID(), 'Washer/Dryer', 'Appliances', 'In-unit or on-site laundry facilities');

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for property search with location and amenities
CREATE VIEW property_search_view AS
SELECT 
    p.property_id,
    p.name,
    p.description,
    p.price_per_night,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    p.property_type,
    l.city,
    l.state_province,
    l.country,
    l.latitude,
    l.longitude,
    u.first_name AS host_first_name,
    u.last_name AS host_last_name,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id) AS review_count,
    GROUP_CONCAT(a.amenity_name) AS amenities
FROM property p
JOIN location l ON p.location_id = l.location_id
JOIN user u ON p.host_id = u.user_id
LEFT JOIN review r ON p.property_id = r.property_id AND r.is_visible = TRUE
LEFT JOIN property_amenity pa ON p.property_id = pa.property_id AND pa.is_available = TRUE
LEFT JOIN amenity a ON pa.amenity_id = a.amenity_id
WHERE p.is_active = TRUE AND p.is_available = TRUE
GROUP BY p.property_id;

-- View for booking history with payment status
CREATE VIEW booking_history_view AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.guest_count,
    b.status AS booking_status,
    p.name AS property_name,
    l.city,
    l.country,
    u_guest.first_name AS guest_first_name,
    u_guest.last_name AS guest_last_name,
    u_host.first_name AS host_first_name,
    u_host.last_name AS host_last_name,
    pay.payment_status,
    pay.amount AS payment_amount,
    b.created_at
FROM booking b
JOIN property p ON b.property_id = p.property_id
JOIN location l ON p.location_id = l.location_id
JOIN user u_guest ON b.user_id = u_guest.user_id
JOIN user u_host ON p.host_id = u_host.user_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;
