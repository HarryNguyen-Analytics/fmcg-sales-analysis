-- Sales Analysis 1 — Overall business performance
select 
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
  round(avg(price_unit),2) as avg_price, 
from `fmcg_sales_analysis.raw_sales`;


-- Sales Analysis 2 — Yearly Sales Performance
select extract(year from date) as sales_year,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
  count(distinct sku) as total_sku
from `fmcg_sales_analysis.raw_sales`
group by sales_year
order by sales_year asc;

-- Sales Analysis 3 - Monthly sales trend
select 
  extract(year from date) as sales_year,
  extract(month from date) as sales_month,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by sales_year, sales_month
order by sales_year, sales_month asc;

-- Sales Analysis 4 - Year-over-year comparison
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
-- Sales Analysis 5 - LAG() growth analysis
-- MoM
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

-- Sales Analysis 6 - Running total
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

