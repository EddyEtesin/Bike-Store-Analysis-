
# Bike Store Analysis - SQL Project

## Overview
This SQL project analyzes a bike store's sales data, customer behavior, inventory management, and staff performance. The analysis provides valuable insights to optimize operations, improve customer experience, and increase revenue.

## Key Analysis Areas

### Sales & Orders
- Top selling products by quantity
- Monthly revenue trends
- High-performing category/brand combinations
- Discount analysis by store and staff
- Shipping delays identification

### Customer Behavior
- Most active customers by order count
- Average order value per customer
- Customer retention analysis
- High-revenue geographic areas

### Inventory & Stock
- Low stock alerts
- Product distribution across stores
- Unsold but stocked products
- Unique product counts per store

### Staff & Performance
- Order processing metrics
- Staff productivity analysis
- Inactive staff identification

### Advanced Analytics
- Price analysis by category/brand
- Seasonal sales trends
- Discount impact on sales
- Order fulfillment efficiency

## SQL Queries Highlights

1. **Top 10 Best-Selling Products**
   ```sql
   SELECT p.product_name, sum(oi.quantity) as quantitysold 
   FROM bike_data.order_items oi 
   join bike_data.products p on oi.product_id = p.product_id
   group by p.product_id,p.product_name
   order by quantitysold desc;
   ```

2. **Monthly Revenue Trends**
   ```sql
   select MONTHNAME(order_date) as Month, 
   sum(Round(quantity*list_price*(1-discount))) as Revenue_gen 
   from bike_data.order_items oi
   join bike_data.orders o on oi.order_id = o.order_id 
   where Year(order_date) = 2018
   group by MONTHNAME(order_date);
   ```

3. **Customer Retention Analysis**
   ```sql
   select c.customer_id, c.first_name, c.last_name, c.email
   from bike_data.customers c
   where c.customer_id not in (
       select distinct o.customer_id
       from bike_data.orders o
       where o.order_date >= (
           select max(order_date) from bike_data.orders
       ) - interval 6 month
   );
   ```

4. **Seasonal Sales Patterns**
   ```sql
   select 
     p.product_name,
     monthname(o.order_date) as month,
     sum(oi.quantity) as total_units_sold
   from bike_data.orders o
   join bike_data.order_items oi on o.order_id = oi.order_id
   join bike_data.products p on oi.product_id = p.product_id
   where o.order_status = 4
   group by p.product_name, monthname(o.order_date)
   order by p.product_name, total_units_sold desc;
   ```

## How to Use This Analysis

1. **For Store Managers**:
   - Identify top-selling products to optimize inventory
   - Monitor low-stock items to prevent stockouts
   - Analyze staff performance metrics

2. **For Marketing Teams**:
   - Target high-value customers with loyalty programs
   - Create promotions based on seasonal trends
   - Adjust discount strategies based on sales impact

3. **For Operations**:
   - Improve fulfillment processes based on timing metrics
   - Address shipping delays
   - Optimize product distribution across stores

## Technical Details

- **Database Schema**: Includes tables for orders, order_items, products, customers, staff, stores, brands, and categories
- **Analysis Period**: Primarily focused on 2018 data
- **Key Metrics**: Revenue, order volume, stock levels, fulfillment time

This comprehensive analysis provides actionable insights to drive business decisions and improve overall store performance.
