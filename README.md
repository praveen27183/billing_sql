# Billing SQL Database

A comprehensive SQL database schema for a billing and invoicing system. This repository contains the complete database structure, sample data, and useful queries for managing customers, products, invoices, and payments.

## Features

- **Customer Management**: Store and manage customer information including contact details and status
- **Product/Service Catalog**: Maintain a catalog of products and services with pricing
- **Invoice Generation**: Create detailed invoices with line items, tax calculations, and discounts
- **Payment Tracking**: Record and track payments against invoices
- **Automated Calculations**: Triggers automatically update invoice totals and payment balances
- **Comprehensive Reporting**: Pre-built queries for common billing reports and analytics

## Database Schema

The database consists of five main tables:

1. **customers**: Customer information and contact details
2. **products**: Product and service catalog with pricing
3. **invoices**: Invoice headers with totals and status
4. **invoice_items**: Individual line items for each invoice
5. **payments**: Payment records linked to invoices

## Files

- **schema.sql**: Complete database schema including tables, indexes, and triggers
- **sample_data.sql**: Sample data for testing and demonstration
- **queries.sql**: Collection of useful queries for reporting and analysis

## Getting Started

### Prerequisites

- MySQL 5.7 or higher (or MariaDB 10.2+)
- MySQL client or GUI tool (MySQL Workbench, phpMyAdmin, etc.)

### Installation

1. **Create the database and tables:**
   ```bash
   mysql -u your_username -p < schema.sql
   ```

2. **Load sample data (optional):**
   ```bash
   mysql -u your_username -p < sample_data.sql
   ```

3. **Run queries:**
   ```bash
   mysql -u your_username -p billing_system < queries.sql
   ```

### Alternative: Run all at once
```bash
cat schema.sql sample_data.sql queries.sql | mysql -u your_username -p
```

## Usage Examples

### Create a New Customer
```sql
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code)
VALUES ('John', 'Smith', 'john.smith@example.com', '555-1234', 
        '123 Main St', 'Boston', 'MA', '02101');
```

### Create an Invoice
```sql
-- First, create the invoice
INSERT INTO invoices (customer_id, invoice_number, invoice_date, due_date, tax_rate)
VALUES (1, 'INV-2026-100', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 8.50);

-- Then add line items (triggers will automatically calculate totals)
INSERT INTO invoice_items (invoice_id, product_id, description, quantity, unit_price, line_total)
VALUES (1, 1, 'Web Hosting - Basic', 1, 9.99, 9.99);
```

### Record a Payment
```sql
INSERT INTO payments (invoice_id, payment_date, amount, payment_method, transaction_id)
VALUES (1, CURDATE(), 100.00, 'credit_card', 'TXN-12345');
```

## Key Features Explained

### Automatic Calculations

The database includes triggers that automatically:
- Update invoice subtotals when items are added/removed/modified
- Calculate tax amounts based on the tax rate
- Update total amounts including discounts
- Track paid amounts from payments
- Calculate remaining balance due
- Update invoice status to 'paid' when fully paid

### Invoice Status Flow

- **draft**: Invoice is being created
- **sent**: Invoice has been sent to customer
- **paid**: Invoice has been fully paid
- **overdue**: Invoice is past due date with outstanding balance
- **cancelled**: Invoice has been cancelled

## Common Queries

The `queries.sql` file includes ready-to-use queries for:

- Customer billing summaries
- Overdue invoice reports
- Payment history and analysis
- Revenue reporting by month
- Top customers by revenue
- Product/service sales analysis
- Outstanding balance reports

## Database Diagram

```
customers (1) ----< (M) invoices (1) ----< (M) invoice_items (M) >---- (1) products
                            |
                            |
                            v
                       (1) ----< (M) payments
```

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is open source and available for educational and commercial use.

## Support

For questions or support, please open an issue in the repository.