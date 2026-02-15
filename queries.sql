-- Common Billing Queries
-- This file contains useful queries for the billing system

USE billing_system;

-- ========================================
-- CUSTOMER QUERIES
-- ========================================

-- Get all active customers
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name, 
       email, phone, city, state
FROM customers
WHERE status = 'active'
ORDER BY last_name, first_name;

-- Get customer with their total billing amount
SELECT c.customer_id, 
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       COUNT(i.invoice_id) AS total_invoices,
       IFNULL(SUM(i.total_amount), 0) AS total_billed,
       IFNULL(SUM(i.paid_amount), 0) AS total_paid,
       IFNULL(SUM(i.balance_due), 0) AS total_outstanding
FROM customers c
LEFT JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_outstanding DESC;

-- ========================================
-- INVOICE QUERIES
-- ========================================

-- Get all invoices with customer details
SELECT i.invoice_id, i.invoice_number, i.invoice_date, i.due_date,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       i.subtotal, i.tax_amount, i.total_amount, 
       i.paid_amount, i.balance_due, i.status
FROM invoices i
JOIN customers c ON i.customer_id = c.customer_id
ORDER BY i.invoice_date DESC;

-- Get overdue invoices
SELECT i.invoice_id, i.invoice_number, i.due_date,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email, c.phone,
       i.total_amount, i.paid_amount, i.balance_due,
       DATEDIFF(CURDATE(), i.due_date) AS days_overdue
FROM invoices i
JOIN customers c ON i.customer_id = c.customer_id
WHERE i.balance_due > 0 
  AND i.due_date < CURDATE()
  AND i.status NOT IN ('paid', 'cancelled')
ORDER BY days_overdue DESC;

-- Get invoice details with all items
SELECT i.invoice_number, i.invoice_date, i.due_date,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       p.product_name,
       ii.quantity,
       ii.unit_price,
       ii.line_total,
       i.subtotal,
       i.tax_amount,
       i.total_amount,
       i.status
FROM invoices i
JOIN customers c ON i.customer_id = c.customer_id
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
JOIN products p ON ii.product_id = p.product_id
ORDER BY i.invoice_date DESC, i.invoice_number, ii.item_id;

-- Get unpaid invoices
SELECT i.invoice_id, i.invoice_number, i.invoice_date, i.due_date,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       i.total_amount, i.paid_amount, i.balance_due
FROM invoices i
JOIN customers c ON i.customer_id = c.customer_id
WHERE i.balance_due > 0 AND i.status != 'cancelled'
ORDER BY i.due_date;

-- ========================================
-- PAYMENT QUERIES
-- ========================================

-- Get all payments with invoice details
SELECT p.payment_id, p.payment_date, p.amount, p.payment_method,
       i.invoice_number, i.total_amount,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM payments p
JOIN invoices i ON p.invoice_id = i.invoice_id
JOIN customers c ON i.customer_id = c.customer_id
ORDER BY p.payment_date DESC;

-- Get payment summary by method
SELECT payment_method,
       COUNT(*) AS payment_count,
       SUM(amount) AS total_amount
FROM payments
GROUP BY payment_method
ORDER BY total_amount DESC;

-- Get monthly payment summary
SELECT YEAR(payment_date) AS year,
       MONTH(payment_date) AS month,
       DATE_FORMAT(payment_date, '%Y-%m') AS year_month,
       COUNT(*) AS payment_count,
       SUM(amount) AS total_received
FROM payments
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY year DESC, month DESC;

-- ========================================
-- PRODUCT/SERVICE QUERIES
-- ========================================

-- Get product sales summary
SELECT p.product_id, p.product_name, p.product_type,
       COUNT(ii.item_id) AS times_sold,
       SUM(ii.quantity) AS total_quantity,
       SUM(ii.line_total) AS total_revenue
FROM products p
LEFT JOIN invoice_items ii ON p.product_id = ii.product_id
WHERE p.is_active = TRUE
GROUP BY p.product_id, p.product_name, p.product_type
ORDER BY total_revenue DESC;

-- ========================================
-- REPORTING QUERIES
-- ========================================

-- Revenue summary by month
SELECT DATE_FORMAT(i.invoice_date, '%Y-%m') AS month,
       COUNT(DISTINCT i.invoice_id) AS invoice_count,
       SUM(i.subtotal) AS subtotal,
       SUM(i.tax_amount) AS tax,
       SUM(i.total_amount) AS total_revenue,
       SUM(i.paid_amount) AS collected,
       SUM(i.balance_due) AS outstanding
FROM invoices i
WHERE i.status != 'cancelled'
GROUP BY DATE_FORMAT(i.invoice_date, '%Y-%m')
ORDER BY month DESC;

-- Customer revenue ranking
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       COUNT(i.invoice_id) AS invoice_count,
       SUM(i.total_amount) AS total_revenue,
       SUM(i.paid_amount) AS total_paid,
       AVG(i.total_amount) AS avg_invoice_amount
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
WHERE i.status != 'cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
HAVING total_revenue > 0
ORDER BY total_revenue DESC
LIMIT 10;

-- Outstanding balance by customer
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email, c.phone,
       COUNT(i.invoice_id) AS unpaid_invoices,
       SUM(i.balance_due) AS total_outstanding
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
WHERE i.balance_due > 0 AND i.status NOT IN ('paid', 'cancelled')
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone
ORDER BY total_outstanding DESC;

-- Invoice status summary
SELECT status,
       COUNT(*) AS count,
       SUM(total_amount) AS total_amount,
       SUM(paid_amount) AS paid_amount,
       SUM(balance_due) AS balance_due
FROM invoices
GROUP BY status
ORDER BY status;
