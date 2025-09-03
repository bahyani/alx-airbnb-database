# Normalization: Task 2

# Database Normalization Requirements - Property Booking System

## Executive Summary

After analyzing the current database schema, I found that the design is **already well-normalized** and meets Third Normal Form (3NF) requirements. However, I identified several areas for improvement to enhance data integrity, reduce redundancy, and support future scalability.

## Current Schema Analysis

### 1. First Normal Form (1NF) Compliance ✅

**Requirements:**
- Each table has a primary key
- All attributes contain atomic values
- No repeating groups

**Status:** **COMPLIANT**
- All tables have UUID primary keys
- All attributes contain single, atomic values
- No multi-valued attributes or repeating groups found

### 2. Second Normal Form (2NF) Compliance ✅

**Requirements:**
- Must be in 1NF
- All non-key attributes must be fully functionally dependent on the primary key

**Status:** **COMPLIANT**
- All tables use single-column primary keys (UUIDs)
- No partial dependencies exist since all primary keys are single attributes
- All non-key attributes depend entirely on their respective primary keys

### 3. Third Normal Form (3NF) Compliance ✅

**Requirements:**
- Must be in 2NF
- No transitive dependencies (non-key attributes should not depend on other non-key attributes)

**Status:** **MOSTLY COMPLIANT** with minor improvements needed

## Identified Issues and Improvements

### Issue 1: Location Data Normalization

**Current State:**
```sql
PROPERTY {
    location VARCHAR NOT NULL  -- Single field for location
}
```

**Problem:** 
- Location stored as a single string may contain multiple pieces of information (city, state, country, zip code)
- Difficult to query by specific location components
- Potential data inconsistency in format

**Proposed Solution:**
Create a separate `LOCATION` entity to normalize geographic data.

### Issue 2: Payment Method Normalization

**Current State:**
```sql
PAYMENT {
    payment_method ENUM(credit_card, paypal, stripe) NOT NULL
}
```

**Problem:**
- Hard-coded payment methods in ENUM
- Difficult to add new payment methods without schema changes
- No additional metadata storage for payment methods

**Proposed Solution:**
Create a separate `PAYMENT_METHOD` entity for better extensibility.

### Issue 3: User Role Normalization

**Current State:**
```sql
USER {
    role ENUM(guest, host, admin) NOT NULL
}
```

**Problem:**
- Fixed roles may not support future role-based permissions
- No ability to store role-specific metadata

**Proposed Solution:**
Create a separate `ROLE` entity for role-based access control.

## Normalized Database Schema

### New/Modified Entities

#### 1. LOCATION Entity
```sql
CREATE TABLE LOCATION (
    location_id UUID PRIMARY KEY,
    street_address VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. PAYMENT_METHOD Entity
```sql
CREATE TABLE PAYMENT_METHOD (
    payment_method_id UUID PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    processing_fee_percentage DECIMAL(5,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 3. ROLE Entity
```sql
CREATE TABLE ROLE (
    role_id UUID PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. PROPERTY_AMENITY and AMENITY Entities (Additional Normalization)
```sql
CREATE TABLE AMENITY (
    amenity_id UUID PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PROPERTY_AMENITY (
    property_amenity_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    amenity_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES AMENITY(amenity_id) ON DELETE CASCADE,
    UNIQUE(property_id, amenity_id)
);
```

### Modified Existing Entities

#### Updated PROPERTY Table
```sql
CREATE TABLE PROPERTY (
    property_id UUID PRIMARY KEY,
    host_id UUID NOT NULL,
    location_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    max_guests INTEGER NOT NULL,
    bedrooms INTEGER,
    bathrooms INTEGER,
    property_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES USER(user_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES LOCATION(location_id) ON DELETE RESTRICT
);
```

#### Updated USER Table
```sql
CREATE TABLE USER (
    user_id UUID PRIMARY KEY,
    role_id UUID NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    profile_picture_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES ROLE(role_id) ON DELETE RESTRICT
);
```

#### Updated PAYMENT Table
```sql
CREATE TABLE PAYMENT (
    payment_id UUID PRIMARY KEY,
    booking_id UUID NOT NULL,
    payment_method_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    transaction_id VARCHAR(255) UNIQUE,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES BOOKING(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES PAYMENT_METHOD(payment_method_id) ON DELETE RESTRICT
);
```

## Normalization Steps Applied

### Step 1: Eliminate Transitive Dependencies
- **Location normalization**: Removed potential transitive dependency where city might depend on postal code
- **Payment method normalization**: Eliminated hard-coded ENUMs that could create maintenance dependencies

### Step 2: Atomic Value Enforcement
- **Location decomposition**: Split single location field into atomic components (street, city, state, country)
- **Enhanced user data**: Added atomic fields for better user profile management

### Step 3: Redundancy Elimination
- **Amenities normalization**: Created many-to-many relationship for property amenities to eliminate repetition
- **Reference data normalization**: Moved payment methods and roles to separate tables

### Step 4: Data Integrity Enhancement
- **Foreign key constraints**: Added proper referential integrity with CASCADE and RESTRICT options
- **Check constraints**: Enhanced data validation rules
- **Unique constraints**: Prevented duplicate reference data

## Benefits of Normalization

### 1. **Reduced Data Redundancy**
- Location information stored once and referenced
- Payment method details centralized
- Role definitions reusable across users

### 2. **Improved Data Integrity**
- Referential integrity through foreign keys
- Standardized location and payment method data
- Consistent role-based access control

### 3. **Enhanced Maintainability**
- Easy to add new payment methods without schema changes
- Centralized location management
- Role permissions can be modified without touching user records

### 4. **Better Query Performance**
- Indexed location components for geographic searches
- Efficient joins through proper normalization
- Reduced data duplication improves storage efficiency

### 5. **Future Scalability**
- Extensible payment method system
- Flexible role-based permissions
- Support for advanced location-based features

## Verification of 3NF Compliance

### Final 3NF Check:

1. **1NF**: ✅ All attributes are atomic, tables have primary keys
2. **2NF**: ✅ All non-key attributes fully depend on primary keys
3. **3NF**: ✅ No transitive dependencies exist:
   - Location components don't depend on each other transitively
   - Payment method details are separated from transaction data
   - Role information is independent of user-specific data
   - Amenities are properly normalized through junction table

## Implementation Recommendations

### Phase 1: Core Normalization
1. Create LOCATION, ROLE, and PAYMENT_METHOD tables
2. Migrate existing data to new normalized structure
3. Update foreign key relationships

### Phase 2: Enhanced Features
1. Implement AMENITY and PROPERTY_AMENITY tables
2. Add geographic indexing for location-based searches
3. Implement role-based permission system

### Phase 3: Data Migration Strategy
1. **Backup existing data**
2. **Create new normalized tables**
3. **Migrate data with proper validation**
4. **Update application code to use new schema**
5. **Drop old denormalized columns**

## Required Indexes

```sql
-- Location indexes for geographic searches
CREATE INDEX idx_location_city ON LOCATION(city);
CREATE INDEX idx_location_country ON LOCATION(country);
CREATE INDEX idx_location_coordinates ON LOCATION(latitude, longitude);

-- User indexes
CREATE INDEX idx_user_email ON USER(email);
CREATE INDEX idx_user_role ON USER(role_id);

-- Property indexes
CREATE INDEX idx_property_host ON PROPERTY(host_id);
CREATE INDEX idx_property_location ON PROPERTY(location_id);
CREATE INDEX idx_property_price ON PROPERTY(price_per_night);

-- Booking indexes
CREATE INDEX idx_booking_property ON BOOKING(property_id);
CREATE INDEX idx_booking_user ON BOOKING(user_id);
CREATE INDEX idx_booking_dates ON BOOKING(start_date, end_date);

-- Payment indexes
CREATE INDEX idx_payment_booking ON PAYMENT(booking_id);
CREATE INDEX idx_payment_method ON PAYMENT(payment_method_id);
CREATE INDEX idx_payment_status ON PAYMENT(payment_status);
```

## Conclusion

The original schema was already well-designed and mostly compliant with 3NF. The proposed normalization improvements focus on:

- **Future-proofing**: Making the system more extensible
- **Data quality**: Improving consistency and integrity
- **Performance**: Enabling better indexing and querying
- **Maintainability**: Reducing the need for schema changes

These changes maintain the existing functionality while providing a more robust foundation for future enhancements.

## Next Steps

1. Review and approve the normalized schema design 2. Create migration 
scripts for existing data 3. Update application code to work with new 
schema 4. Implement the changes in a staging environment first 5. Plan 
production deployment with minimal downtime

