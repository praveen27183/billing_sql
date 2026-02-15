CREATE DATABASE billing_db;
USE billing_db;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(200)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    stock INT
);

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    invoice_date DATETIME,
    total_amount DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE invoice_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT,
    product_id INT,
    quantity INT,
    subtotal DECIMAL(10,2),

    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO customers (name,email,phone,address) VALUES
('Akash','akash@gmail.com','9876543210','Chennai'),
('Rahul','rahul@gmail.com','9876500000','Mumbai'),
('Priya','priya@gmail.com','9876511111','Delhi'),
('Arun','arun@gmail.com','9876522222','Bangalore'),
('Sneha','sneha@gmail.com','9876533333','Hyderabad');
SELECT * FROM customers;

INSERT INTO products (product_name,price,stock) VALUES
('Laptop',50000,10),
('Mouse',500,50),
('Keyboard',1000,40),
('Monitor',12000,20),
('Headphones',2000,30);
SELECT * FROM products;

INSERT INTO invoices (customer_id,invoice_date,total_amount) VALUES
(1,NOW(),51000),
(2,NOW(),13000),
(3,NOW(),2000);
SELECT * FROM invoices;

INSERT INTO invoice_items (invoice_id,product_id,quantity,subtotal) VALUES
(1,1,1,50000),
(1,2,2,1000),
(2,4,1,12000),
(2,3,1,1000),
(3,5,1,2000);

UPDATE products SET stock = stock - 1 WHERE product_id = 1;
UPDATE products SET stock = stock - 2 WHERE product_id = 2;
UPDATE products SET stock = stock - 1 WHERE product_id = 4;
UPDATE products SET stock = stock - 1 WHERE product_id = 3;
UPDATE products SET stock = stock - 1 WHERE product_id = 5;

SELECT
customers.name,
products.product_name,
invoice_items.quantity,
invoice_items.subtotal,
invoices.invoice_date
FROM invoice_items
JOIN invoices ON invoices.invoice_id = invoice_items.invoice_id
JOIN customers ON customers.customer_id = invoices.customer_id
JOIN products ON products.product_id = invoice_items.product_id;

SELECT SUM(total_amount) AS total_sales
FROM invoices;

SELECT
product_id,
SUM(quantity) AS total_sold
FROM invoice_items
GROUP BY product_id
ORDER BY total_sold DESC;

CREATE VIEW billing_report AS
SELECT
customers.name,
products.product_name,
invoice_items.quantity,
invoice_items.subtotal,
invoices.invoice_date
FROM invoice_items
JOIN invoices ON invoices.invoice_id = invoice_items.invoice_id
JOIN customers ON customers.customer_id = invoices.customer_id
JOIN products ON products.product_id = invoice_items.product_id;
DELIMITER $$

CREATE FUNCTION calculate_gst_bill(amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

RETURN amount * 0.18;

END $$

DELIMITER ;


DELIMITER $$

CREATE FUNCTION calculate_gst_bill(amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

RETURN amount * 0.18;

END $$

DELIMITER ;
