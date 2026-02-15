#!/bin/bash

# Billing System Database Setup Script
# This script automates the installation of the billing system database

set -e  # Exit on error

echo "========================================="
echo "Billing System Database Setup"
echo "========================================="
echo ""

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "Error: MySQL is not installed or not in PATH"
    echo "Please install MySQL and try again"
    exit 1
fi

# Prompt for MySQL credentials
read -p "Enter MySQL username (default: root): " MYSQL_USER
MYSQL_USER=${MYSQL_USER:-root}

read -sp "Enter MySQL password: " MYSQL_PASSWORD
echo ""
echo ""

# Test MySQL connection
echo "Testing MySQL connection..."
if ! mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" &> /dev/null; then
    echo "Error: Could not connect to MySQL"
    echo "Please check your credentials and try again"
    exit 1
fi
echo "✓ Connected to MySQL successfully"
echo ""

# Prompt for what to install
echo "What would you like to do?"
echo "1) Install schema only"
echo "2) Install schema and sample data"
echo "3) Install everything (schema, sample data, and run test queries)"
read -p "Enter your choice (1-3): " CHOICE
echo ""

# Install schema
echo "Installing database schema..."
if mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < schema.sql; then
    echo "✓ Schema installed successfully"
else
    echo "✗ Error installing schema"
    exit 1
fi
echo ""

# Install sample data if requested
if [ "$CHOICE" = "2" ] || [ "$CHOICE" = "3" ]; then
    echo "Installing sample data..."
    if mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < sample_data.sql; then
        echo "✓ Sample data installed successfully"
    else
        echo "✗ Error installing sample data"
        exit 1
    fi
    echo ""
fi

# Run test queries if requested
if [ "$CHOICE" = "3" ]; then
    echo "Running test queries..."
    echo ""
    echo "--- Customer Summary ---"
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D billing_system -e "
        SELECT c.customer_id, 
               CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
               COUNT(i.invoice_id) AS total_invoices,
               IFNULL(SUM(i.total_amount), 0) AS total_billed
        FROM customers c
        LEFT JOIN invoices i ON c.customer_id = i.customer_id
        GROUP BY c.customer_id, c.first_name, c.last_name
        ORDER BY total_billed DESC;
    "
    echo ""
    echo "--- Invoice Summary ---"
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -D billing_system -e "
        SELECT status, COUNT(*) AS count, 
               SUM(total_amount) AS total_amount,
               SUM(balance_due) AS balance_due
        FROM invoices
        GROUP BY status;
    "
    echo ""
fi

echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Database: billing_system"
echo "Tables created: customers, products, invoices, invoice_items, payments"
echo ""
echo "You can now connect to the database:"
echo "  mysql -u $MYSQL_USER -p billing_system"
echo ""
echo "See queries.sql for useful example queries."
