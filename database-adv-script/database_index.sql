-- =====================================================
-- Database Index Creation for Performance Optimization
-- Property Booking System
-- =====================================================

-- =====================================================
-- USER TABLE INDEXES
-- =====================================================

-- Index on email (frequently used in WHERE clauses for login/authentication)
CREATE INDEX idx_user_email_lookup ON user(email);

-- Index on user status for filtering active users
CREATE INDEX idx_user_status ON user(is_active, is_verified);

-- Composite index for user search by name
CREATE INDEX idx_user_fullname ON user(first_name, last_name);

-- Index on role_id for user role filtering
CREATE INDEX idx_user_role_filter ON user(role_id);

-- =====================================================
-- BOOKING TABLE INDEXES
-- =====================================================

-- Index on user_id (foreign key, frequently joined)
CREATE INDEX idx_booking_user ON booking(user_id);

-- Index on property_id (foreign key, frequently joined)
CREATE INDEX idx_booking_property ON booking(property_id);

-- Composite index for date range queries (availability checking)
CREATE INDEX idx_booking_dates ON booking(start_date, end_date);

-- Index on booking status (frequently filtered)
CREATE INDEX idx_booking_status ON booking(status);

-- Composite index for property availability queries
CREATE INDEX idx_booking_property_dates ON booking(property_id, start_date, end_date, status);

-- Index on created_at for chronological ordering
CREATE INDEX idx_booking_created ON booking(created_at);

-- =====================================================
-- PROPERTY TABLE INDEXES
-- =====================================================

-- Index on host_id (foreign key, frequently joined)
CREATE INDEX idx_property_host ON property(host_id);

-- Index on location_id (foreign key, frequently joined)
CREATE INDEX idx_property_location ON property(location_id);

-- Index on price for price range filtering
CREATE INDEX idx_property_price ON property(price_per_night);

-- Index on property availability and status
CREATE INDEX idx_property_availability ON property(is_active, is_available);

-- Composite index for property search queries
CREATE INDEX idx_property_search ON property(location_id, is_active, is_available, price_per_night);

-- Index on guest capacity for filtering
CREATE INDEX idx_property_guests ON property(max_guests);

-- Index on property type for categorization
CREATE INDEX idx_property_type ON property(property_type);

-- =====================================================
-- ADDITIONAL PERFORMANCE INDEXES
-- =====================================================

-- Review table indexes
CREATE INDEX idx_review_property ON review(property_id);
CREATE INDEX idx_review_user ON review(user_id);
CREATE INDEX idx_review_rating ON review(rating);
CREATE INDEX idx_review_visible ON review(is_visible);

-- Payment table indexes
CREATE INDEX idx_payment_booking ON payment(booking_id);
CREATE INDEX idx_payment_status ON payment(payment_status);
CREATE INDEX idx_payment_date ON payment(payment_date);

-- Location table indexes for geographical searches
CREATE INDEX idx_location_city ON location(city);
CREATE INDEX idx_location_coordinates ON location(latitude, longitude);

-- Message table indexes
CREATE INDEX idx_message_recipient ON message(recipient_id);
CREATE INDEX idx_message_sender ON message(sender_id);
CREATE INDEX idx_message_conversation ON message(sender_id, recipient_id, sent_at);
