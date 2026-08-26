-- Product Analysi 1 — Which product categories generate the most revenue and units sold?

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

-- Product Analysis 2 — What percentage of total revenue does each category contribute?
with category_with_grand_total_revenue as (
select category,
sum(units_sold) as total_sold,
round(sum(price_unit*units_sold),2) as category_revenue,
sum(sum(price_unit*units_sold)) over() as grand_total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by category)

select cr.category, cr.total_sold ,cr.category_revenue, cr.grand_total_revenue,
round(cr.category_revenue/cr.grand_total_revenue*100,2) as revenue_contribution_pct
from category_with_grand_total_revenue cr
order by revenue_contribution_pct desc;

-- Yogurt contributed the largest share of total revenue at 41.23%, followed by Milk at 20.53%.
-- ReadyMeal and SnackBar contributed 17.93% and 17.05% respectively, while Juice accounted for only 3.27% of total revenue.


-- Product Analysis 3 — Which SKUs generate the highest revenue?
with sku_revenue_summary as (
select
  category,
  sku,
  sum(units_sold) as total_sold,
  round(sum(price_unit*units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by category, sku)

select sm.category, sm.sku, sm.total_sold, sm.total_revenue,
rank() over (order by sm.total_revenue desc) as rank_sku
from sku_revenue_summary sm
order by rank_sku;
-- Result: YO-029 was the highest-revenue SKU, generating approximately $931.9K, followed by YO-005 and YO-012. 
-- The top three SKUs were all from the Yogurt category, supporting Yogurt's strong overall category performance.

-- Product Analysis 4 — Which SKUs perform best within each category?
with sku_revenue_summary as (
select
  category,
  sku,
  sum(units_sold) as total_sold,
  round(sum(price_unit*units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by category, sku)

select sm.category, sm.sku, sm.total_sold, sm.total_revenue,
rank() over (partition by sm.category order by sm.total_revenue desc) as rank_sku
from sku_revenue_summary sm
order by sm.category, rank_sku;

-- Result:
-- The highest-revenue SKUs varied by category. 
-- MI-026 ranked first within Milk, RE-004 led ReadyMeal, SN-010 led SnackBar, and JU-021 was the only SKU within Juice. 
-- Category-level ranking highlights the strongest individual products within each product group rather than comparing all SKUs against one another.

-- Product Analysis 5 - Which SKUs introduced during the 2023 portfolio expansion generated the most revenue?
-- Business Context:
-- The dataset shows 20 active SKUs in 2022, increasing to 30 in 2023.
-- The portfolio remained unchanged at 30 SKUs in 2024.
-- Therefore, 2023 is the only observed expansion period, with 10 new SKUs
-- entering the portfolio. This analysis evaluates the performance of those
-- newly introduced products.
select
    category,
    sku,
    MIN(date) as first_launch,
    sum(units_sold) as total_units_sold,
    round(sum(price_unit*units_sold),2) as total_revenue
from `fmcg_sales_analysis.raw_sales`
group by category, sku
having EXTRACT(YEAR FROM MIN(date)) = 2023
order by total_revenue desc;
