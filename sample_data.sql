-- Sample Data for Billing System
-- This file contains sample data to demonstrate the billing system

USE billing_system;

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code, country, status) VALUES
('John', 'Doe', 'john.doe@example.com', '555-0101', '123 Main St', 'New York', 'NY', '10001', 'USA', 'active'),
('Jane', 'Smith', 'jane.smith@example.com', '555-0102', '456 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA', 'active'),
('Michael', 'Johnson', 'michael.j@example.com', '555-0103', '789 Pine Rd', 'Chicago', 'IL', '60601', 'USA', 'active'),
('Emily', 'Brown', 'emily.brown@example.com', '555-0104', '321 Elm St', 'Houston', 'TX', '77001', 'USA', 'active'),
('David', 'Wilson', 'david.wilson@example.com', '555-0105', '654 Maple Dr', 'Phoenix', 'AZ', '85001', 'USA', 'active');

-- Insert sample products/services
INSERT INTO products (product_name, description, unit_price, product_type, is_active) VALUES
('Web Hosting - Basic', 'Basic web hosting package with 10GB storage', 9.99, 'service', TRUE),
('Web Hosting - Premium', 'Premium web hosting with unlimited storage', 24.99, 'service', TRUE),
('Domain Registration', 'Annual domain registration', 12.99, 'service', TRUE),
('SSL Certificate', 'SSL certificate for one year', 49.99, 'service', TRUE),
('Consulting Hour', 'IT consulting services per hour', 75.00, 'service', TRUE),
('Website Development', 'Custom website development', 1500.00, 'service', TRUE),
('Email Service', 'Business email hosting per month', 5.99, 'service', TRUE),
('Backup Service', 'Automated backup service per month', 15.00, 'service', TRUE);

-- Insert sample invoices
INSERT INTO invoices (customer_id, invoice_number, invoice_date, due_date, tax_rate, discount_amount, status) VALUES
(1, 'INV-2026-001', '2026-01-01', '2026-01-31', 8.50, 0.00, 'paid'),
(2, 'INV-2026-002', '2026-01-05', '2026-02-04', 8.50, 10.00, 'paid'),
(3, 'INV-2026-003', '2026-01-10', '2026-02-09', 8.50, 0.00, 'sent'),
(4, 'INV-2026-004', '2026-01-15', '2026-02-14', 8.50, 25.00, 'sent'),
(5, 'INV-2026-005', '2026-02-01', '2026-03-03', 8.50, 0.00, 'draft');

-- Insert sample invoice items
INSERT INTO invoice_items (invoice_id, product_id, description, quantity, unit_price, line_total) VALUES
-- Invoice 1 items
(1, 2, 'Web Hosting - Premium (Monthly)', 1, 24.99, 24.99),
(1, 3, 'Domain Registration', 1, 12.99, 12.99),
(1, 4, 'SSL Certificate', 1, 49.99, 49.99),

-- Invoice 2 items
(2, 1, 'Web Hosting - Basic (Monthly)', 3, 9.99, 29.97),
(2, 7, 'Email Service (Monthly)', 5, 5.99, 29.95),

-- Invoice 3 items
(3, 6, 'Website Development', 1, 1500.00, 1500.00),
(3, 5, 'Consulting Hours', 10, 75.00, 750.00),

-- Invoice 4 items
(4, 2, 'Web Hosting - Premium (Annual)', 12, 24.99, 299.88),
(4, 8, 'Backup Service (Annual)', 12, 15.00, 180.00),

-- Invoice 5 items
(5, 5, 'Consulting Hours', 5, 75.00, 375.00),
(5, 7, 'Email Service', 2, 5.99, 11.98);

-- Insert sample payments
INSERT INTO payments (invoice_id, payment_date, amount, payment_method, transaction_id, notes) VALUES
(1, '2026-01-25', 87.97, 'credit_card', 'TXN-CC-001', 'Full payment received'),
(2, '2026-01-28', 54.98, 'bank_transfer', 'TXN-BT-002', 'Payment received via bank transfer');

-- Display summary
SELECT 'Sample data inserted successfully!' AS status;
