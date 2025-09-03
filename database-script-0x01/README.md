Property Booking System Database
A comprehensive, normalized database schema for a property rental/booking platform (similar to Airbnb) built with modern database design principles.
📋 Table of Contents

Overview
Features
Database Schema
Installation
Usage
Database Structure
Performance
Contributing
License

🏠 Overview
This project provides a complete database solution for a property booking platform that supports:

User Management: Guest, Host, and Admin roles with flexible permissions
Property Listings: Detailed property information with location and amenity management
Booking System: Full reservation workflow with status tracking
Payment Processing: Multi-method payment system with fee tracking
Review System: Multi-dimensional rating and review system
Messaging: User-to-user communication system
Location Services: Normalized geographic data for search optimization

✨ Features
🔧 Technical Features

Third Normal Form (3NF) Compliant: Eliminates data redundancy and ensures integrity
UUID Primary Keys: Better for distributed systems and security
Comprehensive Indexing: Optimized for common query patterns
Foreign Key Constraints: Maintains referential integrity
Data Validation: CHECK constraints for business rule enforcement
Audit Trails: Created/updated timestamps on all entities

🎯 Business Features

Multi-Role System: Flexible role-based access control
Property Management: Detailed property specifications and amenities
Booking Workflow: Complete reservation lifecycle management
Payment Integration: Support for multiple payment methods
Geographic Search: Location-based property discovery
Review System: Detailed ratings across multiple dimensions
Communication: Threaded messaging between users

🗃️ Database Schema
The database consists of 11 main tables organized into logical groups:
Reference Tables

role - User roles and permissions
payment_method - Payment method configurations
location - Normalized address data
amenity - Property amenities catalog

Core Entities

user - User profiles and authentication
property - Property listings and details

Transactions

booking - Reservation records
payment - Payment transactions

Interactions

review - Property reviews and ratings
message - User communications

Junction Tables

property_amenity - Property-amenity relationships

🚀 Installation
Prerequisites

MySQL 8.0+ or MariaDB 10.5+
Database client (MySQL Workbench, phpMyAdmin, or command line)
