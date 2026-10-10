-- =====================================================================
-- ShopLite Sample Catalog Seed Data
-- 16 realistic products across Electronics, Fashion, Home, Accessories
-- Idempotent: Uses ON DUPLICATE KEY UPDATE to avoid duplicates
-- =====================================================================

USE shoplite_db;

INSERT INTO products (id, name, description, price, category, image_url, rating, stock_quantity)
VALUES
-- Electronics
(
    1,
    'SonicPro Wireless Noise-Cancelling Headphones',
    'Premium over-ear headphones featuring hybrid active noise cancellation, 40-hour battery life, and crystal-clear acoustic fidelity.',
    129.99,
    'Electronics',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80',
    4.8,
    35
),
(
    2,
    'AuraFit Smart Fitness Watch',
    'Water-resistant smartwatch with continuous heart-rate monitoring, SpO2 sensor, AMOLED touch display, and 14-day battery life.',
    89.50,
    'Electronics',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop&q=80',
    4.6,
    42
),
(
    3,
    'Vortex RGB Mechanical Gaming Keyboard',
    'Tenkeyless mechanical keyboard featuring tactile brown switches, per-key RGB backlighting, and a solid aluminum chassis.',
    74.99,
    'Electronics',
    'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800&auto=format&fit=crop&q=80',
    4.7,
    28
),
(
    4,
    'PulseBoom Portable Bluetooth Speaker',
    'Compact 360-degree wireless speaker with deep bass, IPX7 waterproof rating, and 20 hours of continuous playtime.',
    49.99,
    'Electronics',
    'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=800&auto=format&fit=crop&q=80',
    4.5,
    50
),

-- Fashion
(
    5,
    'Urban Classic Rugged Denim Jacket',
    'Timeless relaxed-fit denim jacket crafted from 100% durable cotton with antique brass buttons and deep side pockets.',
    64.00,
    'Fashion',
    'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=800&auto=format&fit=crop&q=80',
    4.4,
    25
),
(
    6,
    'AeroStride Lightweight Running Shoes',
    'Breathable mesh knit running sneakers with responsive foam cushioning and high-traction rubber outsole.',
    79.95,
    'Fashion',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&auto=format&fit=crop&q=80',
    4.7,
    30
),
(
    7,
    'Heritage Canvas & Leather Weekender Duffel',
    'Spacious weekend travel bag combining heavy-duty waxed canvas with genuine full-grain leather straps and brass hardware.',
    115.00,
    'Fashion',
    'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&auto=format&fit=crop&q=80',
    4.9,
    18
),
(
    8,
    'Polarized Classic Aviator Sunglasses',
    'Lightweight stainless steel frame with scratch-resistant polarized lenses offering 100% UV400 solar protection.',
    38.50,
    'Fashion',
    'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=800&auto=format&fit=crop&q=80',
    4.3,
    60
),

-- Home
(
    9,
    'Artisan Ceramic Pour-Over Coffee Maker',
    'Handcrafted ceramic dripper and heat-resistant borosilicate glass carafe for cafe-quality slow drip coffee.',
    34.99,
    'Home',
    'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
    4.7,
    40
),
(
    10,
    'Zenith Ergonomic Contour Memory Foam Pillow',
    'Orthopedic neck-support pillow with cooling gel-infused memory foam and a removable, washable bamboo fiber cover.',
    42.00,
    'Home',
    'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=800&auto=format&fit=crop&q=80',
    4.5,
    32
),
(
    11,
    'HydroShield Insulated Stainless Steel Tumbler (750ml)',
    'Double-wall vacuum insulated bottle keeping drinks ice cold for 24 hours or steaming hot for 12 hours.',
    27.50,
    'Home',
    'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800&auto=format&fit=crop&q=80',
    4.8,
    75
),
(
    12,
    'Lumina Minimalist Touch-Control LED Desk Lamp',
    'Eye-caring architectural desk lamp with 5 color temperatures, step-less dimming, and built-in USB charging port.',
    39.99,
    'Home',
    'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=800&auto=format&fit=crop&q=80',
    4.6,
    22
),

-- Accessories
(
    13,
    'VoltSnap 10000mAh Magnetic Wireless Power Bank',
    'Slim magnetic wireless battery pack compatible with MagSafe, featuring 20W PD fast charging via USB-C.',
    45.00,
    'Accessories',
    'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=800&auto=format&fit=crop&q=80',
    4.6,
    55
),
(
    14,
    'Sleek Minimalist RFID-Blocking Leather Cardholder',
    'Slim front-pocket wallet handcrafted from top-grain leather with aluminum RFID blocking card ejection mechanism.',
    29.99,
    'Accessories',
    'https://images.unsplash.com/photo-1627123424574-724758594e93?w=800&auto=format&fit=crop&q=80',
    4.7,
    48
),
(
    15,
    'Weatherproof Padded Laptop Sleeve (15.6 Inch)',
    'Water-repellent polyester sleeve with ultra-thick fleece interior lining and an accessory pocket for charger & mouse.',
    24.95,
    'Accessories',
    'https://images.unsplash.com/photo-1544816155-12df9643f363?w=800&auto=format&fit=crop&q=80',
    4.4,
    65
),
(
    16,
    'Heavy-Duty Braided Nylon USB-C Cable (3-Pack)',
    'Durable 6.6ft cables supporting 100W Power Delivery and high-speed data transfer with reinforced strain relief.',
    18.99,
    'Accessories',
    'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=800&auto=format&fit=crop&q=80',
    4.8,
    90
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description),
    price = VALUES(price),
    category = VALUES(category),
    image_url = VALUES(image_url),
    rating = VALUES(rating),
    stock_quantity = VALUES(stock_quantity);
