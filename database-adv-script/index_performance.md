### TASK3

# Database Index Performance Analysis

## Task 3: Database Indexing for Query Performance Optimization

### Objective
Identify high-usage columns and create appropriate indexes to improve query performance in the Property Booking System database.

## High-Usage Columns Identified

### User Table
- **email**: Used in WHERE clauses for authentication and user lookup
- **is_active, is_verified**: Frequently filtered for user status
- **first_name, last_name**: Used in ORDER BY and search operations
- **role_id**: Foreign key frequently joined

### Booking Table
- **user_id**: Foreign key, heavily used in JOINs
- **property_id**: Foreign key, heavily used in JOINs
- **start_date, end_date**: Critical for availability queries and date range filtering
- **status**: Frequently filtered (confirmed, cancelled, pending, etc.)
- **created_at**: Used for chronological ordering

### Property Table
- **host_id**: Foreign key, frequently joined with user table
- **location_id**: Foreign key, joined with location table for geographical queries
- **price_per_night**: Used in range queries and ORDER BY clauses
- **is_active, is_available**: Frequently filtered for property availability
- **max_guests**: Used in WHERE clauses for capacity filtering
- **property_type**: Used for categorization and filtering

## Index Creation Commands (database_index.sql)

### User Table Indexes
```sql
CREATE INDEX idx_user_email_lookup ON user(email);
CREATE INDEX idx_user_status ON user(is_active, is_verified);
CREATE INDEX idx_user_fullname ON user(first_name, last_name);
CREATE INDEX idx_user_role_filter ON user(role_id);
```

### Booking Table Indexes
```sql
CREATE INDEX idx_booking_user ON booking(user_id);
CREATE INDEX idx_booking_property ON booking(property_id);
CREATE INDEX idx_booking_dates ON booking(start_date, end_date);
CREATE INDEX idx_booking_status ON booking(status);
CREATE INDEX idx_booking_property_dates ON booking(property_id, start_date, end_date, status);
CREATE INDEX idx_booking_created ON booking(created_at);
```

### Property Table Indexes
```sql
CREATE INDEX idx_property_host ON property(host_id);
CREATE INDEX idx_property_location ON property(location_id);
CREATE INDEX idx_property_price ON property(price_per_night);
CREATE INDEX idx_property_availability ON property(is_active, is_available);
CREATE INDEX idx_property_search ON property(location_id, is_active, is_available, price_per_night);
CREATE INDEX idx_property_guests ON property(max_guests);
CREATE INDEX idx_property_type ON property(property_type);
```

## Query Performance Analysis

### Before Index Creation

#### Sample Query 1: Find Available Properties
```sql
EXPLAIN SELECT * FROM property p 
WHERE p.is_active = TRUE 
AND p.is_available = TRUE 
AND p.price_per_night BETWEEN 100 AND 300;
```

**Expected Performance Issues:**
- Full table scan on property table
- No index utilization
- High execution time for large datasets

#### Sample Query 2: Check Booking Availability
```sql
EXPLAIN SELECT * FROM booking 
WHERE property_id = 'some-uuid' 
AND start_date <= '2024-12-01' 
AND end_date >= '2024-11-25' 
AND status IN ('confirmed', 'checked_in');
```

**Expected Performance Issues:**
- Sequential scan through booking table
- Date comparison on every row
- No index on composite search criteria

### After Index Creation

#### Sample Query 1: Find Available Properties (With Indexes)
**Expected Improvements:**
- Uses `idx_property_search` composite index
- Index range scan instead of full table scan
- 70-90% reduction in execution time

#### Sample Query 2: Check Booking Availability (With Indexes)
**Expected Improvements:**
- Uses `idx_booking_property_dates` composite index
- Direct index lookup by property_id
- 80-95% reduction in execution time

## Performance Measurement Commands

### Using EXPLAIN to analyze query execution plans:
```sql
EXPLAIN FORMAT=JSON SELECT * FROM property WHERE is_active = TRUE AND price_per_night < 200;
```

### Using ANALYZE for detailed performance metrics:
```sql
SET profiling = 1;
SELECT * FROM property WHERE is_active = TRUE AND price_per_night BETWEEN 100 AND 300;
SHOW PROFILES;
```

## Expected Performance Improvements
- **Property searches**: 70-90% faster
- **Booking availability checks**: 80-95% faster  
- **User lookup operations**: 85-95% faster
- **JOIN operations**: 60-80% faster 
