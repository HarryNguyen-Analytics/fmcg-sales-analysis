-- =========================================================
-- 03. SALES PERFORMANCE ANALYSIS
-- =========================================================

-- =========================================================
-- Sales Analysis 1
-- What is the overall sales performance of the business?
-- =========================================================

select 
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
  round(avg(price_unit),2) as avg_price, 
from `fmcg_sales_analysis.raw_sales`;

/*
Result:
The dataset generated approximately $19.95M in total revenue
from 3.80M units sold, with an average observed unit price of $5.25.
*/


-- =========================================================
-- Sales Analysis 2
-- How has annual sales performance changed over time?
-- =========================================================

select extract(year from date) as sales_year,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
  count(distinct sku) as total_sku
from `fmcg_sales_analysis.raw_sales`
group by sales_year
order by sales_year asc;

/*
Result:
Revenue increased from approximately $3.17M in 2022
to $8.44M in 2023, while the active product portfolio expanded
from 20 to 30 SKUs. Revenue remained broadly stable in 2024
at approximately $8.35M.
*/


-- =========================================================
-- Sales Analysis 3
-- What is the monthly sales trend across the analysis period?
-- =========================================================

select 
  extract(year from date) as sales_year,
  extract(month from date) as sales_month,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by sales_year, sales_month
order by sales_year, sales_month asc;

/*
Result:
Monthly sales increased substantially during the 2022–2023
portfolio expansion period and then remained relatively stable
throughout 2024.
*/

-- =========================================================
-- Sales Analysis 4
-- How did annual revenue change compared with the previous year?
-- =========================================================

with yearly_sales as(
  select extract (year from date) as sales_year,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by sales_year
),

prev_year_revenue_summary as (
select sales_year, total_sold, total_revenue,
lag(total_revenue) over(order by sales_year) as prev_year_revenue,
from yearly_sales)

select sales_year, total_sold, total_revenue,prev_year_revenue,
round(
    (total_revenue - prev_year_revenue)/prev_year_revenue*100,2
) as YoY_growth
from prev_year_revenue_summary
order by sales_year asc;

/*
Result:
Annual revenue increased by 166.38% in 2023 compared with 2022,
while 2024 revenue decreased slightly by 1.05% compared with 2023.
*/

-- =========================================================
-- Sales Analysis 5
-- How does monthly revenue change compared with the previous month?
-- =========================================================
with monthly_sales_summary as (
select
  extract(year from date) as sales_year,
  extract(month from date) as sales_month,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by sales_year, sales_month ),

prev_month_revenue_summary as (
select ms.sales_year, ms.sales_month, ms.total_sold, ms.total_revenue,
lag(ms.total_revenue) over (order by ms.sales_year, ms.sales_month asc) as prev_month_revenue
from monthly_sales_summary ms)

select pv.sales_year, pv.sales_month, pv.total_sold, pv.total_revenue, pv.prev_month_revenue,
round((pv.total_revenue - pv.prev_month_revenue )/pv.prev_month_revenue*100,) as mom_growth_pct
from prev_month_revenue_sumary pv

/*
Result:
Month-over-month analysis highlights periods of revenue growth
and decline across the full 2022–2024 sales timeline.
*/

-- =========================================================
-- Sales Analysis 6
-- How has cumulative revenue developed over time?
-- =========================================================
  
with monthly_sales_summary as (
select
  extract(year from date) as sales_year,
  extract(month from date) as sales_month,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by sales_year, sales_month )

select ms.sales_year, ms.sales_month, ms.total_sold, ms.total_revenue,
sum(ms.total_revenue) over (order by ms.sales_year, ms.sales_month asc) as running_revenue
from monthly_sales_summary ms
order by ms.sales_year, ms.sales_month asc;

/*
Result:
Cumulative revenue increased throughout the analysis period,
reaching approximately $19.95M by the end of 2024.
*/
