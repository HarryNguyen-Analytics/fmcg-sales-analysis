-- Business question 1:
-- Which product categories generate the most revenue and units sold?

select
  category,
  count(distinct sku) as active_sku,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue
from `fmcg_sales_analysis.raw_sales`
group by category
order by total_revenue desc;
-- Yogurt was the highest-performing category, generating approximately $8.23M in revenue and 1.57M units sold.
-- It also had the broadest product assortment with 11 active SKUs.
-- Milk ranked second with approximately $4.10M in revenue, followed by ReadyMeal, SnackBar, and Juice.

