#erDiagram

    USER {
        UUID user_id PK "Primary Key, Indexed"
        VARCHAR first_name "NOT NULL"
        VARCHAR last_name "NOT NULL"
        VARCHAR email "UNIQUE, NOT NULL, Indexed"
        VARCHAR password_hash "NOT NULL"
        VARCHAR phone_number "NULL"
        ENUM role "guest|host|admin, NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
    }

    PROPERTY {
        UUID property_id PK "Primary Key, Indexed"
        UUID host_id FK "Foreign Key → User"
        VARCHAR name "NOT NULL"
        TEXT description "NOT NULL"
        VARCHAR location "NOT NULL"
        DECIMAL price_per_night "NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
        TIMESTAMP updated_at "ON UPDATE CURRENT_TIMESTAMP"
    }

    BOOKING {
        UUID booking_id PK "Primary Key, Indexed"
        UUID property_id FK "Foreign Key → Property"
        UUID user_id FK "Foreign Key → User"
        DATE start_date "NOT NULL"
        DATE end_date "NOT NULL"
        DECIMAL total_price "NOT NULL"
        ENUM status "pending|confirmed|canceled, NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
    }

    PAYMENT {
        UUID payment_id PK "Primary Key, Indexed"
        UUID booking_id FK "Foreign Key → Booking"
        DECIMAL amount "NOT NULL"
        TIMESTAMP payment_date "DEFAULT CURRENT_TIMESTAMP"
        ENUM payment_method "credit_card|paypal|stripe, NOT NULL"
    }

    REVIEW {
        UUID review_id PK "Primary Key, Indexed"
        UUID property_id FK "Foreign Key → Property"
        UUID user_id FK "Foreign Key → User"
        INTEGER rating "CHECK: rating >= 1 AND rating <= 5, NOT NULL"
        TEXT comment "NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
    }

    MESSAGE {
        UUID message_id PK "Primary Key, Indexed"
        UUID sender_id FK "Foreign Key → User"
        UUID recipient_id FK "Foreign Key → User"
        TEXT message_body "NOT NULL"
        TIMESTAMP sent_at "DEFAULT CURRENT_TIMESTAMP"
    }

    %% Relationships
    USER ||--o{ PROPERTY : "hosts (1:M)"
    USER ||--o{ BOOKING : "makes (1:M)"
    PROPERTY ||--o{ BOOKING : "is_booked (1:M)"
    BOOKING ||--|| PAYMENT : "has_payment (1:1)"
    USER ||--o{ REVIEW : "writes (1:M)"
    PROPERTY ||--o{ REVIEW : "receives (1:M)"
    USER ||--o{ MESSAGE : "sends (1:M)"
    USER ||--o{ MESSAGE : "receives (1:M)"
