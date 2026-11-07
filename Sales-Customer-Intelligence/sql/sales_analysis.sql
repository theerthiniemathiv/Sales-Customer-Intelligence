
-- SALES PERFORMANCE & CUSTOMER INSIGHTS PROJECT
-- SQL Business Analysis Reports

-- 1. Monthly Revenue
SELECT strftime('%Y-%m', transaction_at) AS month,
       SUM(item_price_amount) AS revenue
FROM sales
GROUP BY month
ORDER BY month;

-- 2. Top 10 Products by Revenue
SELECT item_name, SUM(item_price_amount) AS total_revenue
FROM sales
GROUP BY item_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Top 10 Customers by Revenue
SELECT customer_code, SUM(item_price_amount) AS total_revenue
FROM sales
GROUP BY customer_code
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Average Order Value
SELECT ROUND(
    SUM(item_price_amount) / COUNT(DISTINCT invoice_code), 2
) AS average_order_value
FROM sales;

-- 5. Customer Purchase Frequency
SELECT customer_code,
       COUNT(DISTINCT invoice_code) AS total_orders
FROM sales
GROUP BY customer_code
ORDER BY total_orders DESC;

-- 6. Monthly Revenue Growth
WITH monthly_sales AS (
    SELECT strftime('%Y-%m', transaction_at) AS month,
           SUM(item_price_amount) AS revenue
    FROM sales
    GROUP BY month
),
growth AS (
    SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly_sales
)
SELECT month, revenue, previous_revenue,
       ROUND((revenue - previous_revenue)
       * 100.0 / previous_revenue, 2) AS growth_percentage
FROM growth
ORDER BY month;

-- 7. Product Revenue Ranking
SELECT item_name,
       SUM(item_price_amount) AS total_revenue,
       RANK() OVER (ORDER BY SUM(item_price_amount) DESC) AS revenue_rank
FROM sales
GROUP BY item_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 8. Repeat vs One-Time Customers
WITH customer_orders AS (
    SELECT customer_code,
           COUNT(DISTINCT invoice_code) AS total_orders,
           SUM(item_price_amount) AS total_revenue
    FROM sales
    GROUP BY customer_code
)
SELECT
    CASE WHEN total_orders = 1
         THEN 'One-Time Customer'
         ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count,
    SUM(total_revenue) AS total_revenue
FROM customer_orders
GROUP BY customer_type;

-- 9. Customer Lifetime Revenue
SELECT customer_code,
       COUNT(DISTINCT invoice_code) AS total_orders,
       SUM(item_price_amount) AS lifetime_revenue
FROM sales
GROUP BY customer_code
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- 10. Cumulative Monthly Revenue
WITH monthly_sales AS (
    SELECT strftime('%Y-%m', transaction_at) AS month,
           SUM(item_price_amount) AS monthly_revenue
    FROM sales
    GROUP BY month
)
SELECT month, monthly_revenue,
       SUM(monthly_revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM monthly_sales
ORDER BY month;

-- 11. Top 5 Customers by Purchase Frequency
SELECT customer_code,
       COUNT(DISTINCT invoice_code) AS total_orders,
       SUM(item_price_amount) AS total_revenue
FROM sales
GROUP BY customer_code
ORDER BY total_orders DESC
LIMIT 5;
