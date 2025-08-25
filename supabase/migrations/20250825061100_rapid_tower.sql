/*
  # Coolie Furniture Ecommerce Database Schema

  1. New Tables
    - `categories`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `description` (text)
      - `image_url` (text)
      - `created_at` (timestamp)
    
    - `products`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `price` (decimal)
      - `category_id` (uuid, foreign key)
      - `images` (json array)
      - `specifications` (json object)
      - `stock_quantity` (integer)
      - `is_featured` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `orders`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `total_amount` (decimal)
      - `status` (text)
      - `shipping_address` (json object)
      - `created_at` (timestamp)
    
    - `order_items`
      - `id` (uuid, primary key)
      - `order_id` (uuid, foreign key)
      - `product_id` (uuid, foreign key)
      - `quantity` (integer)
      - `unit_price` (decimal)

  2. Security
    - Enable RLS on all tables
    - Add policies for public product reading
    - Add policies for authenticated user orders
    - Add admin policies for product management
*/

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text,
  image_url text,
  created_at timestamptz DEFAULT now()
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price decimal(10,2) NOT NULL,
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  images json DEFAULT '[]'::json,
  specifications json DEFAULT '{}'::json,
  stock_quantity integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  total_amount decimal(10,2) NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
  shipping_address json NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price decimal(10,2) NOT NULL
);

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Categories policies
CREATE POLICY "Categories are viewable by everyone"
  ON categories FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only authenticated users can manage categories"
  ON categories FOR ALL
  TO authenticated
  USING (true);

-- Products policies
CREATE POLICY "Products are viewable by everyone"
  ON products FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only authenticated users can manage products"
  ON products FOR ALL
  TO authenticated
  USING (true);

-- Orders policies
CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Order items policies
CREATE POLICY "Users can view their own order items"
  ON order_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create order items for their orders"
  ON order_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- Insert sample categories
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