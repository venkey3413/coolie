-- Create database and user
CREATE DATABASE coolie_db;
CREATE USER coolie_user WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE coolie_db TO coolie_user;

-- Connect to the database
\c coolie_db;

-- Create tables
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  images JSON DEFAULT '[]'::json,
  specifications JSON DEFAULT '{}'::json,
  stock_quantity INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
  shipping_address JSON NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL
);

-- Create indexes for better performance
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_is_featured ON products(is_featured);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- Insert sample data
INSERT INTO categories (name, description, image_url) VALUES
  ('Living Room', 'Comfortable and stylish furniture for your living space', 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg'),
  ('Bedroom', 'Rest and relaxation furniture for the perfect bedroom', 'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg'),
  ('Dining Room', 'Elegant dining furniture for memorable meals', 'https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg'),
  ('Office', 'Professional and ergonomic furniture for productivity', 'https://images.pexels.com/photos/159844/cellular-education-classroom-159844.jpeg'),
  ('Storage', 'Smart storage solutions for every room', 'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg');

-- Insert sample products
INSERT INTO products (name, description, price, category_id, images, specifications, stock_quantity, is_featured) 
SELECT 
  'Modern Sectional Sofa',
  'Luxurious 3-piece sectional sofa perfect for large living rooms. Features premium fabric upholstery and solid wood frame.',
  1299.99,
  c.id,
  '["https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg", "https://images.pexels.com/photos/2029694/pexels-photo-2029694.jpeg"]',
  '{"material": "Premium Fabric", "dimensions": "120\" x 80\" x 35\"", "weight": "180 lbs", "color": "Charcoal Gray"}',
  15,
  true
FROM categories c WHERE c.name = 'Living Room'
UNION ALL
SELECT 
  'Executive Office Chair',
  'Ergonomic executive chair with lumbar support and premium leather finish. Perfect for long work sessions.',
  549.99,
  c.id,
  '["https://images.pexels.com/photos/541522/pexels-photo-541522.jpeg"]',
  '{"material": "Genuine Leather", "dimensions": "26\" x 28\" x 46\"", "weight": "45 lbs", "adjustable_height": true}',
  25,
  true
FROM categories c WHERE c.name = 'Office'
UNION ALL
SELECT 
  'Rustic Dining Table',
  'Handcrafted solid wood dining table that seats 6 people comfortably. Features a beautiful rustic finish.',
  899.99,
  c.id,
  '["https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg"]',
  '{"material": "Solid Oak Wood", "dimensions": "72\" x 36\" x 30\"", "weight": "120 lbs", "seats": 6}',
  8,
  false
FROM categories c WHERE c.name = 'Dining Room'
UNION ALL
SELECT 
  'Platform Bed Frame',
  'Modern minimalist bed frame with built-in nightstands. No box spring required.',
  699.99,
  c.id,
  '["https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg"]',
  '{"material": "Engineered Wood", "dimensions": "Queen Size", "weight": "85 lbs", "box_spring_required": false}',
  12,
  true
FROM categories c WHERE c.name = 'Bedroom';

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO coolie_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO coolie_user;