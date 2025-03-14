
-- Updated Database Schema for Multi-language Classified Ads System

DROP DATABASE IF EXISTS classified_ads;
CREATE DATABASE classified_ads;
USE classified_ads;

-- Members Table
CREATE TABLE members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table (Multi-language support)
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name_en VARCHAR(255) NOT NULL,
    name_fr VARCHAR(255) NOT NULL,
    description_en TEXT,
    description_fr TEXT
);

-- Subcategories Table
CREATE TABLE subcategories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    name_fr VARCHAR(255) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Ads Table
CREATE TABLE ads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    category_id INT NOT NULL,
    subcategory_id INT DEFAULT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    start_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (subcategory_id) REFERENCES subcategories(id) ON DELETE SET NULL
);

-- Ad Images Table
CREATE TABLE ad_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ad_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    FOREIGN KEY (ad_id) REFERENCES ads(id) ON DELETE CASCADE
);

-- Admins Table
CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- Offers Table
CREATE TABLE offers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ad_id INT NOT NULL,
    sender_id INT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ad_id) REFERENCES ads(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES members(id) ON DELETE CASCADE
);

-- Sample Data
INSERT INTO categories (name_en, name_fr, description_en, description_fr) VALUES
('Electronics', 'Électronique', 'Electronic gadgets and accessories.', 'Gadgets électroniques et accessoires'),
('Furniture', 'Meubles', 'Home and office furniture.', 'Meubles de maison et de bureau');

INSERT INTO subcategories (category_id, name_en, name_fr) VALUES
(1, 'Smartphones', 'Téléphones intelligents'),
(1, 'Laptops', 'Ordinateurs portables'),
(2, 'Chairs', 'Chaises'),
(2, 'Tables', 'Tables');

INSERT INTO members (name, address, city, state, phone, email, password, status) VALUES
('John Doe', '123 Main Street', 'Montreal', 'Quebec', '1234567890', 'john@example.com',
 '$2y$10$z.XsJUtTS7Bb.Tn7jYZzGe0nxUJP1GS6eqj8f5HdAphj5W8NfZ7HG', 'active'),
('Jane Smith', '456 Maple Ave', 'Toronto', 'Ontario', '9876543210', 'jane@example.com',
 '$2y$10$EynJrFt4eHohDoQ6Vwz/7e4s9YbF34brjsrVxPYu2b1W9PzM.rjxC', 'active');

INSERT INTO ads (member_id, category_id, subcategory_id, title, description, price, status, start_date, expiry_date) VALUES
(1, 1, 1, 'iPhone 13 Pro Max', 'Brand new phone, 128GB, Blue.', 999.99, 'active', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY)),
(2, 2, 4, 'Wooden Dining Table', 'Classic 6-seater solid wood dining table.', 450.00, 'active', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY));

INSERT INTO ad_images (ad_id, image_path) VALUES
(1, 'uploads/iphone.jpg'),
(2, 'uploads/dining_table.jpg');

INSERT INTO admins (email, password) VALUES ('admin@postitnow.com', 'admin123');

-- Validation Queries

-- 1. Get Categories in English or French with Descriptions
-- English:
SELECT name_en AS name, description_en AS description FROM categories;
-- French:
SELECT name_fr AS name, description_fr AS description FROM categories;

-- 2. List of Members
SELECT * FROM members;

-- 3. List of Ads for a Given Member (e.g., Member ID = 1)
SELECT * FROM ads WHERE member_id = 1;

-- 4. Non-expired Ads per Category/Subcategory
SELECT ads.*, categories.name_en AS category, subcategories.name_en AS subcategory
FROM ads
JOIN categories ON ads.category_id = categories.id
LEFT JOIN subcategories ON ads.subcategory_id = subcategories.id
WHERE expiry_date >= CURDATE();

-- 5. Non-expired Ads by Title and State or City (example: "iPhone", "Quebec")
SELECT ads.*, members.state, members.city
FROM ads
JOIN members ON ads.member_id = members.id
WHERE ads.expiry_date >= CURDATE()
  AND ads.title LIKE '%iPhone%'
  AND (members.state = 'Quebec' OR members.city = 'Montreal');
