-- =====================================================
-- Property Booking System - Sample Data Population
-- Version: 1.0
-- Description: Realistic sample data for Airbnb-like platform
-- =====================================================

-- Set variables for consistent UUIDs (using deterministic approach for demo)
SET @role_guest = (SELECT role_id FROM role WHERE role_name = 'guest');
SET @role_host = (SELECT role_id FROM role WHERE role_name = 'host');
SET @role_admin = (SELECT role_id FROM role WHERE role_name = 'admin');

-- Payment method IDs
SET @pm_credit_card = (SELECT payment_method_id FROM payment_method WHERE method_name = 'Credit Card');
SET @pm_paypal = (SELECT payment_method_id FROM payment_method WHERE method_name = 'PayPal');
SET @pm_stripe = (SELECT payment_method_id FROM payment_method WHERE method_name = 'Stripe');

-- =====================================================
-- LOCATIONS DATA
-- =====================================================

INSERT INTO location (location_id, street_address, city, state_province, postal_code, country, latitude, longitude) VALUES
-- New York City
('loc-001', '123 Broadway', 'New York', 'New York', '10001', 'United States', 40.7505, -73.9934),
('loc-002', '456 Central Park West', 'New York', 'New York', '10025', 'United States', 40.7829, -73.9654),
('loc-003', '789 Fifth Avenue', 'New York', 'New York', '10128', 'United States', 40.7829, -73.9654),

-- Los Angeles
('loc-004', '321 Hollywood Blvd', 'Los Angeles', 'California', '90028', 'United States', 34.1022, -118.3267),
('loc-005', '654 Venice Beach Walk', 'Los Angeles', 'California', '90291', 'United States', 33.9850, -118.4695),
('loc-006', '987 Sunset Strip', 'West Hollywood', 'California', '90069', 'United States', 34.0901, -118.3850),

-- Miami
('loc-007', '111 Ocean Drive', 'Miami Beach', 'Florida', '33139', 'United States', 25.7907, -80.1300),
('loc-008', '222 Collins Avenue', 'Miami Beach', 'Florida', '33139', 'United States', 25.7907, -80.1300),

-- Chicago
('loc-009', '333 Michigan Avenue', 'Chicago', 'Illinois', '60601', 'United States', 41.8781, -87.6298),
('loc-010', '444 Lake Shore Drive', 'Chicago', 'Illinois', '60611', 'United States', 41.8947, -87.6197),

-- San Francisco
('loc-011', '555 Lombard Street', 'San Francisco', 'California', '94133', 'United States', 37.8019, -122.4194),
('loc-012', '666 Fisherman\'s Wharf', 'San Francisco', 'California', '94133', 'United States', 37.8081, -122.4181),

-- International Locations
('loc-013', '10 Downing Street', 'London', 'England', 'SW1A 2AA', 'United Kingdom', 51.5074, -0.1278),
('loc-014', '25 Rue de Rivoli', 'Paris', 'Île-de-France', '75001', 'France', 48.8566, 2.3522),
('loc-015', '42 Via del Corso', 'Rome', 'Lazio', '00186', 'Italy', 41.9028, 12.4964),
('loc-016', '15 Shibuya Crossing', 'Tokyo', 'Tokyo', '150-0002', 'Japan', 35.6762, 139.6503),
('loc-017', '8 Bondi Beach Road', 'Sydney', 'New South Wales', '2026', 'Australia', -33.8906, 151.2767);

-- =====================================================
-- USERS DATA
-- =====================================================

-- Admin Users
INSERT INTO user (user_id, role_id, first_name, last_name, email, password_hash, phone_number, date_of_birth, is_verified, is_active) VALUES
('user-admin-001', @role_admin, 'Sarah', 'Johnson', 'admin@propertybooking.com', SHA2('AdminPass123!', 256), '+1-555-0001', '1985-03-15', TRUE, TRUE);

-- Host Users (Property Owners)
INSERT INTO user (user_id, role_id, first_name, last_name, email, password_hash, phone_number, date_of_birth, is_verified, is_active) VALUES
('user-host-001', @role_host, 'Michael', 'Chen', 'michael.chen@email.com', SHA2('HostPass123!', 256), '+1-555-1001', '1980-07-22', TRUE, TRUE),
('user-host-002', @role_host, 'Emma', 'Rodriguez', 'emma.rodriguez@email.com', SHA2('HostPass456!', 256), '+1-555-1002', '1978-11-08', TRUE, TRUE),
('user-host-003', @role_host, 'James', 'Wilson', 'james.wilson@email.com', SHA2('HostPass789!', 256), '+1-555-1003', '1983-04-30', TRUE, TRUE),
('user-host-004', @role_host, 'Sophie', 'Martin', 'sophie.martin@email.com', SHA2('HostPass101!', 256), '+33-1-4567-8901', '1975-09-14', TRUE, TRUE),
('user-host-005', @role_host, 'David', 'Thompson', 'david.thompson@email.com', SHA2('HostPass202!', 256), '+44-20-7946-0958', '1982-01-18', TRUE, TRUE),
('user-host-006', @role_host, 'Yuki', 'Tanaka', 'yuki.tanaka@email.com', SHA2('HostPass303!', 256), '+81-3-1234-5678', '1987-06-25', TRUE, TRUE),
('user-host-007', @role_host, 'Isabella', 'Garcia', 'isabella.garcia@email.com', SHA2('HostPass404!', 256), '+1-555-1007', '1979-12-03', TRUE, TRUE),
('user-host-008', @role_host, 'Robert', 'Kim', 'robert.kim@email.com', SHA2('HostPass505!', 256), '+1-555-1008', '1984-08-17', TRUE, TRUE);

-- Guest Users (Travelers)
INSERT INTO user (user_id, role_id, first_name, last_name, email, password_hash, phone_number, date_of_birth, is_verified, is_active) VALUES
('user-guest-001', @role_guest, 'Jennifer', 'Davis', 'jennifer.davis@email.com', SHA2('GuestPass123!', 256), '+1-555-2001', '1990-02-14', TRUE, TRUE),
('user-guest-002', @role_guest, 'Alex', 'Brown', 'alex.brown@email.com', SHA2('GuestPass456!', 256), '+1-555-2002', '1992-05-28', TRUE, TRUE),
('user-guest-003', @role_guest, 'Maria', 'Lopez', 'maria.lopez@email.com', SHA2('GuestPass789!', 256), '+1-555-2003', '1988-09-12', TRUE, TRUE),
('user-guest-004', @role_guest, 'Kevin', 'Wang', 'kevin.wang@email.com', SHA2('GuestPass101!', 256), '+1-555-2004', '1995-11-07', TRUE, TRUE),
('user-guest-005', @role_guest, 'Lisa', 'Anderson', 'lisa.anderson@email.com', SHA2('GuestPass202!', 256), '+1-555-2005', '1989-03-21', TRUE, TRUE),
('user-guest-006', @role_guest, 'Daniel', 'Miller', 'daniel.miller@email.com', SHA2('GuestPass303!', 256), '+1-555-2006', '1993-07-16', TRUE, TRUE),
('user-guest-007', @role_guest, 'Ashley', 'Taylor', 'ashley.taylor@email.com', SHA2('GuestPass404!', 256), '+1-555-2007', '1991-10-05', TRUE, TRUE),
('user-guest-008', @role_guest, 'Ryan', 'Johnson', 'ryan.johnson@email.com', SHA2('GuestPass505!', 256), '+1-555-2008', '1987-12-19', TRUE, TRUE),
('user-guest-009', @role_guest, 'Amanda', 'White', 'amanda.white@email.com', SHA2('GuestPass606!', 256), '+1-555-2009', '1994-04-02', TRUE, TRUE),
('user-guest-010', @role_guest, 'Christopher', 'Lee', 'chris.lee@email.com', SHA2('GuestPass707!', 256), '+1-555-2010', '1986-08-11', TRUE, TRUE),
('user-guest-011', @role_guest, 'Nicole', 'Harris', 'nicole.harris@email.com', SHA2('GuestPass808!', 256), '+44-20-7123-4567', '1990-01-23', TRUE, TRUE),
('user-guest-012', @role_guest, 'Thomas', 'Clark', 'thomas.clark@email.com', SHA2('GuestPass909!', 256), '+33-1-2345-6789', '1988-06-14', TRUE, TRUE);

-- =====================================================
-- PROPERTIES DATA
-- =====================================================

INSERT INTO property (property_id, host_id, location_id, name, description, price_per_night, max_guests, bedrooms, bathrooms, property_type, total_area_sqft, minimum_stay_nights, maximum_stay_nights) VALUES

-- NYC Properties
('prop-001', 'user-host-001', 'loc-001', 'Modern Manhattan Loft', 'Stunning modern loft in the heart of Manhattan with city views. Perfect for business travelers and tourists alike. Features high-end appliances, comfortable furnishings, and easy access to subway lines.', 275.00, 4, 2, 2, 'Apartment', 1200, 2, 30),

('prop-002', 'user-host-002', 'loc-002', 'Central Park View Studio', 'Charming studio apartment overlooking Central Park. Ideal for couples or solo travelers. Recently renovated with modern amenities while maintaining classic NYC charm.', 180.00, 2, 0, 1, 'Studio', 550, 1, 14),

('prop-003', 'user-host-003', 'loc-003', 'Upper East Side Penthouse', 'Luxurious penthouse apartment with panoramic city views. Three spacious bedrooms, gourmet kitchen, and private terrace. Perfect for families or groups seeking premium accommodations.', 450.00, 6, 3, 3, 'Penthouse', 2200, 3, 60),

-- LA Properties
('prop-004', 'user-host-001', 'loc-004', 'Hollywood Hills Villa', 'Beautiful villa in the famous Hollywood Hills with pool and stunning city views. Perfect for entertaining and relaxing. Features modern amenities, spacious rooms, and outdoor dining area.', 350.00, 8, 4, 3, 'Villa', 3000, 3, 90),

('prop-005', 'user-host-004', 'loc-005', 'Venice Beach Bungalow', 'Cozy beach bungalow just steps from Venice Beach. Enjoy the bohemian atmosphere, street art, and oceanfront lifestyle. Perfect for beach lovers and those wanting authentic LA experience.', 220.00, 4, 2, 2, 'House', 900, 2, 21),

('prop-006', 'user-host-005', 'loc-006', 'West Hollywood Modern Condo', 'Sleek modern condo in trendy West Hollywood. Walking distance to restaurants, nightlife, and shopping. Features floor-to-ceiling windows, designer furnishings, and building amenities.', 195.00, 3, 1, 1, 'Condo', 750, 2, 28),

-- Miami Properties
('prop-007', 'user-host-006', 'loc-007', 'South Beach Art Deco Apartment', 'Historic Art Deco building apartment right on Ocean Drive. Experience the vibrant South Beach lifestyle with direct beach access. Fully renovated interior with period details preserved.', 280.00, 4, 2, 2, 'Apartment', 1100, 2, 30),

('prop-008', 'user-host-007', 'loc-008', 'Miami Beach High-Rise Suite', 'Luxury suite in premium high-rise building with ocean views. Building features include pool, gym, spa, and concierge services. Perfect for those seeking resort-style amenities.', 320.00, 4, 2, 2, 'Condo', 1300, 3, 45),

-- Chicago Properties
('prop-009', 'user-host-008', 'loc-009', 'Downtown Chicago Loft', 'Industrial-chic loft in downtown Chicago with exposed brick and city views. Close to Millennium Park, Art Institute, and business district. Great for both leisure and business travelers.', 200.00, 4, 2, 2, 'Loft', 1000, 2, 30),

('prop-010', 'user-host-002', 'loc-010', 'Lakefront Luxury Apartment', 'Stunning lakefront apartment with panoramic Lake Michigan views. Premium building with doorman, gym, and rooftop deck. Walking distance to Navy Pier and downtown attractions.', 295.00, 4, 2, 2, 'Apartment', 1400, 2, 60),

-- San Francisco Properties
('prop-011', 'user-host-003', 'loc-011', 'Lombard Street Victorian', 'Charming Victorian house near the famous crooked street. Authentic San Francisco architecture with modern updates. Perfect location for exploring the city by foot or public transport.', 240.00, 6, 3, 2, 'House', 1600, 2, 30),

('prop-012', 'user-host-001', 'loc-012', 'Fisherman\'s Wharf Apartment', 'Waterfront apartment with bay views and easy access to Pier 39, Alcatraz tours, and seafood restaurants. Family-friendly location with nearby attractions and public transportation.', 260.00, 4, 2, 2, 'Apartment', 1050, 2, 28),

-- International Properties
('prop-013', 'user-host-005', 'loc-013', 'London Townhouse', 'Traditional English townhouse in prestigious Westminster area. Walking distance to Big Ben, Parliament, and Buckingham Palace. Combines historic charm with modern comfort.', 380.00, 6, 3, 3, 'Townhouse', 1800, 3, 45),

('prop-014', 'user-host-004', 'loc-014', 'Parisian Apartment', 'Classic Parisian apartment in the heart of the city. Near Louvre, Tuileries Garden, and finest shopping. High ceilings, French doors, and authentic Parisian lifestyle experience.', 290.00, 4, 2, 1, 'Apartment', 900, 3, 30),

('prop-015', 'user-host-006', 'loc-015', 'Roman Historical Apartment', 'Beautiful apartment in historic Rome center. Stone\'s throw from Pantheon, Trevi Fountain, and Spanish Steps. Restored historic building with modern amenities and traditional Italian style.', 250.00, 4, 2, 2, 'Apartment', 1000, 2, 30),

('prop-016', 'user-host-006', 'loc-016', 'Tokyo Modern Studio', 'Ultra-modern studio in vibrant Shibuya district. Experience authentic Tokyo lifestyle with easy access to shopping, dining, and nightlife. High-tech amenities and minimalist Japanese design.', 150.00, 2, 0, 1, 'Studio', 400, 1, 21),

('prop-017', 'user-host-008', 'loc-017', 'Sydney Beachfront Apartment', 'Stunning beachfront apartment with direct Bondi Beach access. Watch surfers from your balcony and enjoy the laid-back Australian beach lifestyle. Modern amenities with ocean views.', 210.00, 4, 2, 2, 'Apartment', 950, 2, 28);

-- =====================================================
-- PROPERTY AMENITIES DATA
-- =====================================================

-- Get amenity IDs
SET @amenity_wifi = (SELECT amenity_id FROM amenity WHERE amenity_name = 'WiFi');
SET @amenity_ac = (SELECT amenity_id FROM amenity WHERE amenity_name = 'Air Conditioning');
SET @amenity_kitchen = (SELECT amenity_id FROM amenity WHERE amenity_name = 'Kitchen');
SET @amenity_parking = (SELECT amenity_id FROM amenity WHERE amenity_name = 'Parking');
SET @amenity_pool = (SELECT amenity_id FROM amenity WHERE amenity_name = 'Pool');
SET @amenity_gym = (SELECT amenity_id FROM amenity WHERE amenity_name = 'Gym');
SET @amenity_pet = (SELECT amenity_id FROM amenity WHERE amenity_name = 'Pet Friendly');
SET @amenity_laundry = (SELECT amenity_id FROM amenity WHERE amenity_name = 'Washer/Dryer');

INSERT INTO property_amenity (property_amenity_id, property_id, amenity_id, is_available, notes) VALUES
-- Manhattan Loft amenities
('pa-001', 'prop-001', @amenity_wifi, TRUE, 'High-speed fiber internet'),
('pa-002', 'prop-001', @amenity_ac, TRUE, 'Central air conditioning'),
('pa-003', 'prop-001', @amenity_kitchen, TRUE, 'Fully equipped gourmet kitchen'),
('pa-004', 'prop-001', @amenity_laundry, TRUE, 'In-unit washer and dryer'),

-- Central Park Studio amenities
('pa-005', 'prop-002', @amenity_wifi, TRUE, 'Complimentary WiFi'),
('pa-006', 'prop-002', @amenity_ac, TRUE, 'Window AC unit'),
('pa-007', 'prop-002', @amenity_kitchen, TRUE, 'Kitchenette with essentials'),

-- Hollywood Villa amenities
('pa-008', 'prop-004', @amenity_wifi, TRUE, 'Premium WiFi throughout'),
('pa-009', 'prop-004', @amenity_pool, TRUE, 'Private heated pool'),
('pa-010', 'prop-004', @amenity_parking, TRUE, 'Gated parking for 3 cars'),
('pa-011', 'prop-004', @amenity_kitchen, TRUE, 'Professional-grade kitchen'),
('pa-012', 'prop-004', @amenity_laundry, TRUE, 'Full laundry room'),

-- Venice Beach Bungalow amenities
('pa-013', 'prop-005', @amenity_wifi, TRUE, 'Free WiFi'),
('pa-014', 'prop-005', @amenity_kitchen, TRUE, 'Full kitchen'),
('pa-015', 'prop-005', @amenity_parking, TRUE, 'Driveway parking'),
('pa-016', 'prop-005', @amenity_pet, TRUE, 'Dogs welcome with fee'),

-- Miami Beach properties amenities
('pa-017', 'prop-007', @amenity_wifi, TRUE, 'High-speed internet'),
('pa-018', 'prop-007', @amenity_ac, TRUE, 'Central air'),
('pa-019', 'prop-007', @amenity_pool, TRUE, 'Building pool access'),
('pa-020', 'prop-008', @amenity_wifi, TRUE, 'Premium WiFi'),
('pa-021', 'prop-008', @amenity_pool, TRUE, 'Rooftop infinity pool'),
('pa-022', 'prop-008', @amenity_gym, TRUE, '24/7 fitness center'),

-- Add amenities for other properties (abbreviated for space)
('pa-023', 'prop-009', @amenity_wifi, TRUE, 'Fast internet'),
('pa-024', 'prop-009', @amenity_gym, TRUE, 'Building fitness center'),
('pa-025', 'prop-010', @amenity_wifi, TRUE, 'Fiber internet'),
('pa-026', 'prop-010', @amenity_pool, TRUE, 'Indoor pool'),
('pa-027', 'prop-013', @amenity_wifi, TRUE, 'Complimentary WiFi'),
('pa-028', 'prop-013', @amenity_kitchen, TRUE, 'Traditional English kitchen'),
('pa-029', 'prop-016', @amenity_wifi, TRUE, 'Ultra-fast internet'),
('pa-030', 'prop-017', @amenity_wifi, TRUE, 'Beach WiFi access');

-- =====================================================
-- BOOKINGS DATA
-- =====================================================

INSERT INTO booking (booking_id, property_id, user_id, start_date, end_date, total_price, guest_count, status, special_requests, confirmed_at, created_at) VALUES

-- Completed bookings (past dates)
('book-001', 'prop-001', 'user-guest-001', '2024-11-15', '2024-11-18', 825.00, 2, 'checked_out', 'Late check-in requested', '2024-11-10 14:30:00', '2024-11-08 09:15:00'),
('book-002', 'prop-004', 'user-guest-002', '2024-11-20', '2024-11-25', 1750.00, 4, 'checked_out', 'Anniversary celebration', '2024-11-15 16:45:00', '2024-11-12 11:20:00'),
('book-003', 'prop-007', 'user-guest-003', '2024-12-01', '2024-12-05', 1120.00, 3, 'checked_out', NULL, '2024-11-25 10:15:00', '2024-11-20 14:30:00'),
('book-004', 'prop-002', 'user-guest-004', '2024-12-10', '2024-12-12', 360.00, 1, 'checked_out', 'Business trip', '2024-12-05 13:20:00', '2024-12-03 08:45:00'),
('book-005', 'prop-013', 'user-guest-005', '2024-12-15', '2024-12-20', 1900.00, 4, 'checked_out', 'Family vacation', '2024-12-08 11:30:00', '2024-12-05 16:10:00'),

-- Current/Recent bookings
('book-006', 'prop-011', 'user-guest-006', '2025-01-05', '2025-01-10', 1200.00, 4, 'checked_out', 'New Year getaway', '2024-12-28 15:45:00', '2024-12-22 10:30:00'),
('book-007', 'prop-009', 'user-guest-007', '2025-01-15', '2025-01-18', 600.00, 2, 'checked_out', 'Conference attendance', '2025-01-10 09:15:00', '2025-01-08 14:20:00'),
('book-008', 'prop-016', 'user-guest-008', '2025-02-01', '2025-02-07', 900.00, 2, 'confirmed', 'Cherry blossom season', '2025-01-25 12:30:00', '2025-01-20 11:45:00'),

-- Upcoming bookings
('book-009', 'prop-005', 'user-guest-009', '2025-03-15', '2025-03-20', 1100.00, 3, 'confirmed', 'Spring break vacation', '2025-02-15 14:20:00', '2025-02-10 16:30:00'),
('book-010', 'prop-014', 'user-guest-010', '2025-04-10', '2025-04-17', 2030.00, 2, 'confirmed', 'Honeymoon trip', '2025-03-10 13:15:00', '2025-03-05 09:20:00'),
('book-011', 'prop-008', 'user-guest-011', '2025-05-01', '2025-05-06', 1600.00, 4, 'confirmed', 'Friends reunion', '2025-04-01 10:45:00', '2025-03-28 15:30:00'),
('book-012', 'prop-003', 'user-guest-012', '2025-06-15', '2025-06-20', 2250.00, 6, 'confirmed', 'Family reunion', '2025-05-15 11:20:00', '2025-05-10 14:15:00'),

-- Pending bookings
('book-013', 'prop-017', 'user-guest-001', '2025-07-10', '2025-07-15', 1050.00, 4, 'pending', 'Summer beach vacation', NULL, '2025-06-01 12:30:00'),
('book-014', 'prop-012', 'user-guest-003', '2025-08-05', '2025-08-10', 1300.00, 4, 'pending', 'West Coast tour', NULL, '2025-06-15 16:45:00'),

-- Cancelled bookings
('book-015', 'prop-006', 'user-guest-005', '2025-03-20', '2025-03-25', 975.00, 2, 'canceled', 'Original plan changed', NULL, '2025-02-20 10:15:00'),
('book-016', 'prop-010', 'user-guest-007', '2025-04-25', '2025-04-30', 1475.00, 3, 'canceled', 'Work conflict', NULL, '2025-03-15 14:30:00');

-- =====================================================
-- PAYMENTS DATA
-- =====================================================

INSERT INTO payment (payment_id, booking_id, payment_method_id, amount, transaction_id, payment_status, payment_type, processing_fee, net_amount, processed_at) VALUES

-- Completed payments for checked-out bookings
('pay-001', 'book-001', @pm_credit_card, 825.00, 'txn_001_cc_20241108', 'completed', 'full_payment', 23.93, 801.07, '2024-11-08 09:20:00'),
('pay-002', 'book-002', @pm_stripe, 1750.00, 'txn_002_stripe_20241112', 'completed', 'full_payment', 50.75, 1699.25, '2024-11-12 11:25:00'),
('pay-003', 'book-003', @pm_paypal, 1120.00, 'txn_003_pp_20241120', 'completed', 'full_payment', 38.08, 1081.92, '2024-11-20 14:35:00'),
('pay-004', 'book-004', @pm_credit_card, 360.00, 'txn_004_cc_20241203', 'completed', 'full_payment', 10.44, 349.56, '2024-12-03 08:50:00'),
('pay-005', 'book-005', @pm_stripe, 1900.00, 'txn_005_stripe_20241205', 'completed', 'full_payment', 55.10, 1844.90, '2024-12-05 16:15:00'),
('pay-006', 'book-006', @pm_paypal, 1200.00, 'txn_006_pp_20241222', 'completed', 'full_payment', 40.80, 1159.20, '2024-12-22 10:35:00'),
('pay-007', 'book-007', @pm_credit_card, 600.00, 'txn_007_cc_20250108', 'completed', 'full_payment', 17.40, 582.60, '2025-01-08 14:25:00'),

-- Confirmed booking payments
('pay-008', 'book-008', @pm_stripe, 900.00, 'txn_008_stripe_20250120', 'completed', 'full_payment', 26.10, 873.90, '2025-01-20 11:50:00'),
('pay-009', 'book-009', @pm_credit_card, 1100.00, 'txn_009_cc_20250210', 'completed', 'full_payment', 31.90, 1068.10, '2025-02-10 16:35:00'),
('pay-010', 'book-010', @pm_paypal, 2030.00, 'txn_010_pp_20250305', 'completed', 'full_payment', 69.02, 1960.98, '2025-03-05 09:25:00'),
('pay-011', 'book-011', @pm_stripe, 1600.00, 'txn_011_stripe_20250328', 'completed', 'full_payment', 46.40, 1553.60, '2025-03-28 15:35:00'),
('pay-012', 'book-012', @pm_credit_card, 2250.00, 'txn_012_cc_20250510', 'completed', 'full_payment', 65.25, 2184.75, '2025-05-10 14:20:00'),

-- Pending payments
('pay-013', 'book-013', @pm_paypal, 1050.00, 'txn_013_pp_20250601', 'pending', 'full_payment', 35.70, 1014.30, NULL),
('pay-014', 'book-014', @pm_credit_card, 1300.00, 'txn_014_cc_20250615', 'pending', 'full_payment', 37.70, 1262.30, NULL),

-- Failed/Refunded payments
('pay-015', 'book-015', @pm_stripe, 975.00, 'txn_015_stripe_20250220', 'refunded', 'full_payment', 28.28, 946.72, '2025-02-20 10:20:00'),
('pay-016', 'book-016', @pm_paypal, 1475.00,
