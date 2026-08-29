-- =========================================================
-- 04. PRODUCT ANALYSIS
-- =========================================================


-- =========================================================
-- Product Analysis 1
-- Which product categories generate the most revenue and units sold?
-- =========================================================

select
  category,
  count(distinct sku) as active_sku,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue
from `fmcg_sales_analysis.raw_sales`
group by category
order by total_revenue desc;

/*
Result:
Yogurt was the highest-performing category, generating approximately
$8.23M in revenue and 1.57M units sold. It also had the largest
product assortment with 11 active SKUs.
*/

-- =========================================================
-- Product Analysis 2
-- What percentage of total revenue does each category contribute?
-- =========================================================

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

/*
Result:
Yogurt contributed the largest share of total revenue at 41.23%,
followed by Milk at 20.53%. ReadyMeal and SnackBar contributed
17.93% and 17.05% respectively, while Juice contributed 3.27%.
*/


-- =========================================================
-- Product Analysis 3
-- Which SKUs generate the highest revenue?
-- =========================================================

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

/*
Result:
YO-029 was the highest-revenue SKU at approximately $931.9K,
followed by YO-005 at $913.4K and YO-012 at $899.4K.
The top three SKUs were all from the Yogurt category.
*/

-- =========================================================
-- Product Analysis 4
-- Which SKUs perform best within each category?
-- =========================================================

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

/*
Result:
The highest-revenue SKU in each category was JU-021 for Juice,
MI-026 for Milk, RE-004 for ReadyMeal, SN-010 for SnackBar,
and YO-029 for Yogurt.
*/

-- =========================================================
-- Product Analysis 5
-- Which SKUs introduced during the 2023 portfolio expansion
-- generated the most revenue?
-- =========================================================

select
    category,
    sku,
    MIN(date) as first_launch,
    sum(units_sold) as total_units_sold,
    round(sum(price_unit*units_sold),2) as total_revenue
from `fmcg_sales_analysis.raw_sales`
group by category, sku
  
/*
Result:
Among the 10 SKUs first observed during the 2023 portfolio expansion,
YO-020 generated the highest cumulative revenue at approximately
$636.6K, followed by YO-024 at $582.7K and SN-019 at $581.6K.
*/
having EXTRACT(YEAR FROM MIN(date)) = 2023
order by total_revenue desc;


