-- Sales Analysis 1 — Overall business performance
select 
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
  round(avg(price_unit),2) as avg_price, 
from `fmcg_sales_analysis.raw_sales`;


-- Sales Analysis 2 — Yearly Sales Performance
select extract(year from date) as year_sold,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
  count(distinct sku) as total_sku
from `fmcg_sales_analysis.raw_sales`
group by year_sold
order by year_sold asc;

-- Sales Analysis 3 - Monthly sales trend
select 
  extract(year from date) as year_sold,
  extract(month from date) as month_sold,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by year_sold, month_sold
order by year_sold, month_sold asc;

-- Sales Analysis 4 - Year-over-year comparison
with yearly_sales as(
  select extract (year from date) as year_sold,
  sum(units_sold) as total_sold,
  round(sum(price_unit * units_sold),2) as total_revenue,
from `fmcg_sales_analysis.raw_sales`
group by year_sold
),

year_with_prev as (
select year_sold, total_sold, total_revenue,
lag(total_revenue) over(order by year_sold) as prev_total_revenue,
from yearly_sales)

select year_sold, total_sold, total_revenue,prev_total_revenue,
round(
    (total_revenue - prev_total_revenue)/prev_total_revenue *100,2
) as YoY_growth
from year_with_prev
order by year_sold asc;
-- Sales Analysis 5 - LAG() growth analysis
-- Sales Analysis 6 - Running total
