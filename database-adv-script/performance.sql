SELECT 
   b.booking_id,
   b.start_date,
   b.end_date,
   b.total_price,
   b.guest_count,
   b.status AS booking_status,
   b.created_at AS booking_date,
   
   -- User details
   u.first_name,
   u.last_name,
   u.email,
   
   -- Property details
   p.name AS property_name,
   p.price_per_night,
   p.property_type,
   
   -- Payment details
   pay.amount AS payment_amount,
   pay.payment_status,
   pay.payment_date

FROM booking b
LEFT JOIN user u ON b.user_id = u.user_id
LEFT JOIN property p ON b.property_id = p.property_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;