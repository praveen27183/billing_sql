-- Billing System Database Schema
-- This schema defines the structure for a complete billing system

-- Create database
CREATE DATABASE IF NOT EXISTS billing_system;
USE billing_system;

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'USA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active'
);

-- Products/Services Table
CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    unit_price DECIMAL(10, 2) NOT NULL,
    product_type ENUM('product', 'service') DEFAULT 'product',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Invoices Table
CREATE TABLE IF NOT EXISTS invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    paid_amount DECIMAL(10, 2) DEFAULT 0.00,
    balance_due DECIMAL(10, 2) DEFAULT 0.00,
    status ENUM('draft', 'sent', 'paid', 'overdue', 'cancelled') DEFAULT 'draft',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_invoice_date (invoice_date)
);

-- Invoice Items Table
CREATE TABLE IF NOT EXISTS invoice_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    product_id INT NOT NULL,
    description VARCHAR(255),
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_invoice (invoice_id),
    INDEX idx_product (product_id)
);

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'check', 'credit_card', 'debit_card', 'bank_transfer', 'online') NOT NULL,
    transaction_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE RESTRICT,
    INDEX idx_invoice (invoice_id),
    INDEX idx_payment_date (payment_date)
);

-- Create triggers to automatically update invoice totals
DELIMITER //

CREATE TRIGGER after_invoice_item_insert
AFTER INSERT ON invoice_items
FOR EACH ROW
BEGIN
    DECLARE v_subtotal DECIMAL(10, 2);
    DECLARE v_tax_rate DECIMAL(5, 2);
    DECLARE v_tax_amount DECIMAL(10, 2);
    DECLARE v_discount DECIMAL(10, 2);
    DECLARE v_paid DECIMAL(10, 2);
    DECLARE v_total DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(line_total), 0) INTO v_subtotal
    FROM invoice_items 
    WHERE invoice_id = NEW.invoice_id;
    
    SELECT tax_rate, discount_amount, paid_amount INTO v_tax_rate, v_discount, v_paid
    FROM invoices
    WHERE invoice_id = NEW.invoice_id;
    
    SET v_tax_amount = v_subtotal * (v_tax_rate / 100);
    SET v_total = v_subtotal + v_tax_amount - v_discount;
    
    UPDATE invoices 
    SET subtotal = v_subtotal,
        tax_amount = v_tax_amount,
        total_amount = v_total,
        balance_due = v_total - v_paid
    WHERE invoice_id = NEW.invoice_id;
END;//

CREATE TRIGGER after_invoice_item_update
AFTER UPDATE ON invoice_items
FOR EACH ROW
BEGIN
    DECLARE v_subtotal DECIMAL(10, 2);
    DECLARE v_tax_rate DECIMAL(5, 2);
    DECLARE v_tax_amount DECIMAL(10, 2);
    DECLARE v_discount DECIMAL(10, 2);
    DECLARE v_paid DECIMAL(10, 2);
    DECLARE v_total DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(line_total), 0) INTO v_subtotal
    FROM invoice_items 
    WHERE invoice_id = NEW.invoice_id;
    
    SELECT tax_rate, discount_amount, paid_amount INTO v_tax_rate, v_discount, v_paid
    FROM invoices
    WHERE invoice_id = NEW.invoice_id;
    
    SET v_tax_amount = v_subtotal * (v_tax_rate / 100);
    SET v_total = v_subtotal + v_tax_amount - v_discount;
    
    UPDATE invoices 
    SET subtotal = v_subtotal,
        tax_amount = v_tax_amount,
        total_amount = v_total,
        balance_due = v_total - v_paid
    WHERE invoice_id = NEW.invoice_id;
END;//

CREATE TRIGGER after_invoice_item_delete
AFTER DELETE ON invoice_items
FOR EACH ROW
BEGIN
    DECLARE v_subtotal DECIMAL(10, 2);
    DECLARE v_tax_rate DECIMAL(5, 2);
    DECLARE v_tax_amount DECIMAL(10, 2);
    DECLARE v_discount DECIMAL(10, 2);
    DECLARE v_paid DECIMAL(10, 2);
    DECLARE v_total DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(line_total), 0) INTO v_subtotal
    FROM invoice_items 
    WHERE invoice_id = OLD.invoice_id;
    
    SELECT tax_rate, discount_amount, paid_amount INTO v_tax_rate, v_discount, v_paid
    FROM invoices
    WHERE invoice_id = OLD.invoice_id;
    
    SET v_tax_amount = v_subtotal * (v_tax_rate / 100);
    SET v_total = v_subtotal + v_tax_amount - v_discount;
    
    UPDATE invoices 
    SET subtotal = v_subtotal,
        tax_amount = v_tax_amount,
        total_amount = v_total,
        balance_due = v_total - v_paid
    WHERE invoice_id = OLD.invoice_id;
END;//

CREATE TRIGGER after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE v_paid_amount DECIMAL(10, 2);
    DECLARE v_total_amount DECIMAL(10, 2);
    DECLARE v_balance_due DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(amount), 0) INTO v_paid_amount
    FROM payments 
    WHERE invoice_id = NEW.invoice_id;
    
    SELECT total_amount INTO v_total_amount
    FROM invoices
    WHERE invoice_id = NEW.invoice_id;
    
    SET v_balance_due = v_total_amount - v_paid_amount;
    
    UPDATE invoices 
    SET paid_amount = v_paid_amount,
        balance_due = v_balance_due,
        status = CASE 
            WHEN v_balance_due <= 0 THEN 'paid'
            ELSE status
        END
    WHERE invoice_id = NEW.invoice_id;
END;//

CREATE TRIGGER after_payment_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    DECLARE v_paid_amount DECIMAL(10, 2);
    DECLARE v_total_amount DECIMAL(10, 2);
    DECLARE v_balance_due DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(amount), 0) INTO v_paid_amount
    FROM payments 
    WHERE invoice_id = NEW.invoice_id;
    
    SELECT total_amount INTO v_total_amount
    FROM invoices
    WHERE invoice_id = NEW.invoice_id;
    
    SET v_balance_due = v_total_amount - v_paid_amount;
    
    UPDATE invoices 
    SET paid_amount = v_paid_amount,
        balance_due = v_balance_due,
        status = CASE 
            WHEN v_balance_due <= 0 THEN 'paid'
            ELSE status
        END
    WHERE invoice_id = NEW.invoice_id;
END;//

CREATE TRIGGER after_payment_delete
AFTER DELETE ON payments
FOR EACH ROW
BEGIN
    DECLARE v_paid_amount DECIMAL(10, 2);
    DECLARE v_total_amount DECIMAL(10, 2);
    DECLARE v_balance_due DECIMAL(10, 2);
    
    SELECT IFNULL(SUM(amount), 0) INTO v_paid_amount
    FROM payments 
    WHERE invoice_id = OLD.invoice_id;
    
    SELECT total_amount INTO v_total_amount
    FROM invoices
    WHERE invoice_id = OLD.invoice_id;
    
    SET v_balance_due = v_total_amount - v_paid_amount;
    
    UPDATE invoices 
    SET paid_amount = v_paid_amount,
        balance_due = v_balance_due
    WHERE invoice_id = OLD.invoice_id;
END;//

DELIMITER ;
