# Sample Data (Seed Script) - Property Booking System

This document provides comprehensive information about the sample data population script for the Property Booking System database.

## 📋 Table of Contents

- [Overview](#overview)
- [Data Structure](#data-structure)
- [Installation](#installation)
- [Sample Data Details](#sample-data-details)
- [Usage Examples](#usage-examples)
- [Data Relationships](#data-relationships)
- [Testing Scenarios](#testing-scenarios)
- [Customization](#customization)

## 🌟 Overview

The `seed.sql` script populates the Property Booking System database with realistic sample data that simulates an Airbnb-like environment. This data is perfect for:

- **Development & Testing**: Comprehensive dataset for application development
- **Demo Purposes**: Realistic data for presentations and proof-of-concepts
- **Performance Testing**: Sufficient data volume for query optimization
- **Training**: Learning SQL queries and database operations

## 📊 Data Structure

### Summary Statistics
- **👥 Users**: 21 total (1 admin, 8 hosts, 12 guests)
- **🏠 Properties**: 17 properties across 17 global locations
- **📍 Locations**: 17 cities across 6 countries
- **🛏️ Bookings**: 16 bookings with various statuses
- **💳 Payments**: 16 payment records with different methods
- **⭐ Reviews**: 12 detailed property reviews
- **💬 Messages**: 15 user communications
- **🏷️ Amenities**: 30+ property-amenity associations

### Geographic Distribution
| Country | Cities | Properties |
|---------|---------|------------|
| 🇺🇸 USA | 10 cities | 12 properties |
| 🇬🇧 UK | London | 1 property |
| 🇫🇷 France | Paris | 1 property |
| 🇮🇹 Italy | Rome | 1 property |
| 🇯🇵 Japan | Tokyo | 1 property |
| 🇦🇺 Australia | Sydney | 1 property |

## 🚀 Installation

### Prerequisites
- Database schema must be already created (run `schema.sql` first)
- MySQL 8.0+ or MariaDB 10.5+
- Sufficient database privileges (INSERT, SELECT)

### Installation Steps

1. **Ensure schema is created:**
   ```bash
   mysql -u username -p database_name < schema.sql
   ```

2. **Run the seed script:**
   ```bash
   mysql -u username -p database_name < seed.sql
   ```

3. **Verify data installation:**
   ```sql
   USE property_booking_system;
   
   -- Check record counts
   SELECT 
     (SELECT COUNT(*) FROM user) as users,
     (SELECT COUNT(*) FROM property) as properties,
     (SELECT COUNT(*) FROM booking) as bookings,
     (SELECT COUNT(*) FROM payment) as payments,
     (SELECT COUNT(*) FROM review) as reviews,
     (SELECT COUNT(*) FROM message) as messages;
   ```

## 🏗️ Sample Data Details

### 👤 Users
#### Roles Distribution:
- **1 Admin**: System administrator
- **8 Hosts**: Property owners from different countries
- **12 Guests**: Travelers with diverse backgrounds

#### Sample Users:
```sql
-- Admin
'admin@propertybooking.com' (Sarah Johnson)

-- Hosts
'michael.chen@email.com' (Michael Chen) - NYC & LA properties
'emma.rodriguez@email.com' (Emma Rodriguez) - NYC & Chicago
'sophie.martin@email.com' (Sophie Martin) - Paris
'yuki.tanaka@email.com' (Yuki Tanaka) - Tokyo & Miami

-- Guests  
'jennifer.davis@email.com' (Jennifer Davis)
'alex.brown@email.com' (Alex Brown)
'maria.lopez@email.com' (Maria Lopez)
```

### 🏠 Properties
#### Property Types:
- **Apartments**: 8 properties
- **Studios**: 2 properties
- **Houses/Villas**: 4 properties
- **Condos**: 2 properties
- **Penthouse**: 1 property

#### Price Range:
- **Budget**: $150-200/night (3 properties)
- **Mid-range**: $200-300/night (10 properties)
- **Luxury**: $300-450/night (4 properties)

#### Featured Properties:
```sql
-- NYC Penthouse (Most Expensive)
'Upper East Side Penthouse' - $450/night, 6 guests, 3BR/3BA

-- Tokyo Studio (Most Affordable)
'Tokyo Modern Studio' - $150/night, 2 guests, Studio

-- Hollywood Villa (Largest)
'Hollywood Hills Villa' - $350/night, 8 guests, 4BR/3BA, Pool
```

### 📅 Bookings
#### Booking Status Distribution:
- **Checked Out**: 7 bookings (completed stays)
- **Confirmed**: 5 bookings (upcoming reservations)
- **Pending**: 2 bookings (awaiting confirmation)
- **Canceled**: 2 bookings (cancelled reservations)

#### Date Ranges:
- **Past bookings**: November 2024 - February 2025
- **Current bookings**: March 2025
- **Future bookings**: April - August 2025

### 💳 Payments
#### Payment Methods:
- **Credit Card**: 6 transactions (37.5%)
- **Stripe**: 5 transactions (31.25%)
- **PayPal**: 5 transactions (31.25%)

#### Payment Status:
- **Completed**: 12 payments
- **Pending**: 2 payments
- **Refunded**: 2 payments

### ⭐ Reviews
#### Rating Distribution:
- **5 Stars**: 6 reviews (50%)
- **4 Stars**: 4 reviews (33.3%)
- **3 Stars**: 2 reviews (16.7%)
- **Average Rating**: 4.3/5

#### Review Features:
- Multi-dimensional ratings (cleanliness, communication, location, value)
- Host responses to reviews
- Verified reviews linked to actual bookings

## 💻 Usage Examples

### Basic Queries

#### Find all available properties in NYC:
```sql
SELECT p.name, p.price_per_night, l.city, l.state_province
FROM property p
JOIN location l ON p.location_id = l.location_id
WHERE l.city = 'New York' 
  AND p.is_available = TRUE
ORDER BY p.price_per_night;
```

#### Get booking history for a specific user:
```sql
SELECT 
    b.booking_id,
    p.name as property_name,
    l.city,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM booking b
JOIN property p ON b.property_id = p.property_id
JOIN location l ON p.location_id = l.location_id
JOIN user u ON b.user_id = u.user_id
WHERE u.email = 'jennifer.davis@email.com'
ORDER BY b.created_at DESC;
```

#### Calculate host revenue:
```sql
SELECT 
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) as total_bookings,
    SUM(CASE WHEN b.status = 'checked_out' THEN b.total_price ELSE 0 END) as completed_revenue,
    AVG(r.rating) as avg_rating
FROM user u
JOIN property p ON u.user_id = p.host_id
LEFT JOIN booking b ON p.property_id = b.property_id
LEFT JOIN review r ON p.property_id = r.property_id
WHERE u.role_id = (SELECT role_id FROM role WHERE role_name = 'host')
GROUP BY u.user_id
ORDER BY completed_revenue DESC;
```

### Advanced Queries

#### Property availability check:
```sql
SELECT p.name, p.price_per_night, l.city
FROM property p
JOIN location l ON p.location_id = l.location_id
WHERE p.is_available = TRUE
  AND p.property_id NOT IN (
    SELECT DISTINCT property_id 
    FROM booking 
    WHERE status IN ('confirmed', 'checked_in')
      AND (
        (start_date <= '2025-07-01' AND end_date > '2025-07-01')
        OR (start_date < '2025-07-07' AND end_date >= '2025-07-07')
        OR (start_date >= '2025-07-01' AND end_date <= '2025-07-07')
      )
  );
```

#### Revenue analytics by month:
```sql
SELECT 
    DATE_FORMAT(b.created_at, '%Y-%m') as booking_month,
    COUNT(*) as bookings_count,
    SUM(b.total_price) as gross_revenue,
    SUM(p.net_amount) as net_revenue,
    AVG(b.total_price) as avg_booking_value
FROM booking b
LEFT JOIN payment p ON b.booking_id = p.booking_id
WHERE b.status = 'checked_out'
GROUP BY DATE_FORMAT(b.created_at, '%Y-%m')
ORDER BY booking_month;
```

## 🔗 Data Relationships

### Key Relationships Demonstrated:
1. **User → Property** (Host relationship)
2. **User → Booking** (Guest relationship)  
3. **Property → Booking** (Reservation relationship)
4. **Booking → Payment** (Transaction relationship)
5. **Property → Review** (Rating relationship)
6. **User → Message** (Communication relationship)

### Sample Relationship Queries:
```sql
-- Properties with their hosts and booking counts
SELECT 
    p.name,
    CONCAT(u.first_name, ' ', u.last_name) as host_name,
    COUNT(b.booking_id) as total_bookings,
    AVG(r.rating) as avg_rating
FROM property p
JOIN user u ON p.host_id = u.user_id
LEFT JOIN booking b ON p.property_id = b.property_id
LEFT JOIN review r ON p.property_id = r.property_id
GROUP BY p.property_id, u.user_id;
```

## 🧪 Testing Scenarios

### 1. Booking Workflow Testing:
```sql
-- Test complete booking flow
SELECT 
    b.booking_id,
    b.status as booking_status,
    p.payment_status,
    r.rating as review_rating
FROM booking b
LEFT JOIN payment p ON b.booking_id = p.booking_id
LEFT JOIN review r ON b.booking_id = r.booking_id
WHERE b.booking_id = 'book-001';
```

### 2. User Authentication Testing:
```sql
-- Test user login scenario
SELECT user_id, first_name, last_name, role_name, is_verified
FROM user u
JOIN role r ON u.role_id = r.role_id
WHERE email = 'michael.chen@email.com' 
  AND password_hash = SHA2('HostPass123!', 256);
```

### 3. Search Functionality Testing:
```sql
-- Test property search with filters
SELECT p.name, p.price_per_night, p.max_guests, l.city
FROM property p
JOIN location l ON p.location_id = l.location_id
WHERE l.country = 'United States'
  AND p.price_per_night BETWEEN 200 AND 300
  AND p.max_guests >= 4
  AND p.is_available = TRUE;
```

### 4. Review System Testing:
```sql
-- Test review aggregation
SELECT 
    p.name,
    COUNT(r.review_id) as review_count,
    AVG(r.rating) as avg_overall_rating,
    AVG(r.cleanliness_rating) as avg_cleanliness,
    AVG(r.communication_rating) as avg_communication
FROM property p
LEFT JOIN review r ON p.property_id = r.property_id AND r.is_visible = TRUE
GROUP BY p.property_id
HAVING review_count > 0;
```

## 🎛️ Customization

### Adding More Sample Data:

#### Add New Users:
```sql
INSERT INTO user (user_id, role_id, first_name, last_name, email, password_hash, phone_number, is_verified) 
VALUES (
    UUID(),
    (SELECT role_id FROM role WHERE role_name = 'guest'),
    'New',
    'User',
    'new.user@email.com',
    SHA2('Password123!', 256),
    '+1-555-0000',
    TRUE
);
```

#### Add New Properties:
```sql
-- First add location
INSERT INTO location (location_id, street_address, city, state_province, country, latitude, longitude)
VALUES (UUID(), '123 New Street', 'New City', 'New State', 'Country', 40.7128, -74.0060);

-- Then add property
INSERT INTO property (property_id, host_id, location_id, name, description, price_per_night, max_guests, bedrooms, bathrooms, property_type)
VALUES (
    UUID(),
    'user-host-001',
    (SELECT location_id FROM location WHERE city = 'New City'),
    'New Property',
    'Description of new property',
    199.99,
    4,
    2,
    2,
    'Apartment'
);
```

### Modifying Existing Data:

#### Update Property Prices:
```sql
-- Increase all prices by 10%
UPDATE property 
SET price_per_night = price_per_night * 1.10;
```

#### Add More Reviews:
```sql
INSERT INTO review (review_id, property_id, user_id, rating, comment, cleanliness_rating, communication_rating)
VALUES (
    UUID(),
    'prop-001',
    'user-guest-001',
    5,
    'Excellent property with amazing amenities!',
    5,
    5
);
```

## 🔍 Data Validation

### Verify Data Integrity:
```sql
-- Check for orphaned records
SELECT 'Orphaned Bookings' as check_type, COUNT(*) as count
FROM booking b
LEFT JOIN property p ON b.property_id = p.property_id
WHERE p.property_id IS NULL

UNION ALL

SELECT 'Orphaned Payments', COUNT(*)
FROM payment p
LEFT JOIN booking b ON p.booking_id = b.booking_id
WHERE b.booking_id IS NULL

UNION ALL

SELECT 'Orphaned Reviews', COUNT(*)
FROM review r
LEFT JOIN property p ON r.property_id = p.property_id
WHERE p.property_id IS NULL;
```

### Data Quality Checks:
```sql
-- Check for data consistency
SELECT 
    'Booking dates' as check_type,
    COUNT(*) as violations
FROM booking 
WHERE start_date >= end_date

UNION ALL

SELECT 'Negative prices', COUNT(*)
FROM property
WHERE price_per_night <= 0

UNION ALL

SELECT 'Invalid ratings', COUNT(*)
FROM review
WHERE rating < 1 OR rating > 5;
```

## 🚨 Important Notes

### Data Refresh:
To refresh sample data:
```sql
-- Warning: This will delete all data
DELETE FROM property_amenity;
DELETE FROM message;
DELETE FROM review; 
DELETE FROM payment;
DELETE FROM booking;
DELETE FROM property;
DELETE FROM location WHERE location_id LIKE 'loc-%';
DELETE FROM user WHERE user_id LIKE 'user-%';

-- Then re-run seed.sql
SOURCE seed.sql;
```

### Production Considerations:
- **Never use this seed data in production**
- **Passwords are hashed but predictable**
- **Email addresses are fake**
- **Payment data is simulated**

## 📈 Performance Notes

The sample data is designed to:
- Test index effectiveness with realistic query patterns
- Provide sufficient data volume for performance testing
- Include edge cases (cancelled bookings, refunded payments)
- Demonstrate complex relationships and joins

---

**This seed data provides a solid foundation for development, testing, and demonstration of the Property Booking System!** 🎉
