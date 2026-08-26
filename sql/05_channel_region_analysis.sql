-- Channel & Region Analysis 1 — Which sales channels generate the highest revenue and units sold?
select 
  channel,count( distinct sku) as active_sku,
  sum(units_sold) as total_sold,
  round(sum(price_unit*units_sold),2) as total_revenue
from `fmcg_sales_analysis.raw_sales`
group by channel
order by total_revenue desc;
-- Result:
-- Retail generated the highest revenue at approximately $6.66M, while E-commerce recorded the highest unit sales at 1.27M units.
-- Overall performance was highly balanced across all three channels, with each channel carrying all 30 active SKUs.

-- Channel & Region Analysis 2 — What percentage of total revenue does each sales channel contribute?
with grand_total_reveneu_summary as (
select 
  channel,
  sum(units_sold) as total_sold,
  sum(price_unit*units_sold) as total_revenue,
  sum(sum(price_unit*units_sold)) over () as grand_total_revenue
from `fmcg_sales_analysis.raw_sales`
group by channel)

select gm.channel, gm.total_revenue, gm.grand_total_revenue,
round(gm.total_revenue/ gm.grand_total_revenue *100,2) as countribution_pct
from grand_total_reveneu_summary gm
order by countribution_pct desc;
-- Result:
-- Revenue contribution was almost evenly distributed across all three sales channels.
-- Retail contributed 33.36% of total revenue, followed closely by E-commerce at 33.35% and Discount at 33.29%, indicating no single channel dominated overall revenue performance.


-- Channel & Region Analysis 3 — Which regions generate the highest revenue and units sold?
select 
  region,
  sum(units_sold) as total_sold,
  round(sum(price_unit*units_sold),2) as total_revenue
from `fmcg_sales_analysis.raw_sales`
group by region
order by total_revenue desc;
-- Result:
-- Regional sales performance was highly balanced.
-- PL-South generated the highest revenue at approximately $6.67M, narrowly ahead of PL-North at $6.66M and PL-Central at $6.62M.
-- PL-North recorded the highest unit sales at approximately 1.27M units.

-- Channel & Region Analysis 4 — What percentage of total revenue does each region contribute?
with region_revenue_summary as (
select
  region,
  sum(units_sold) as total_units,
  sum(price_unit * units_sold) as total_revenue,
  sum(sum(price_unit * units_sold)) over() as grand_total_revenue
from `fmcg_sales_analysis.raw_sales`
group by region)

select rs.region, rs.total_units, rs.total_revenue,
round(rs.total_revenue/ rs.grand_total_revenue * 100,2) as contribution_pct
from region_revenue_summary rs
order by contribution_pct desc;

-- Result:
-- Revenue contribution was highly balanced across all three regions. 
-- PL-South contributed the largest share at 33.41%, followed almost identically by PL-North at 33.40%, while PL-Central accounted for 33.19% of total revenue.

-- Channel & Region Analysis 5 — Which sales channel performs best within each region?
with channel_sale_summary as (
select 
  region,
  channel,
  sum(units_sold) as total_sold,
  round(sum(price_unit*units_sold),2) as total_revenue
from `fmcg_sales_analysis.raw_sales`
group by region, channel)

select cm.region, cm.channel, cm.total_sold, cm.total_revenue,
rank() over (partition by cm.region order by cm.total_revenue desc) as channel_rank
from channel_sale_summary cm
order by cm.region, channel_rank;
-- Result:
-- Retail was the highest-revenue channel in both PL-Central and PL-North, while E-commerce ranked first in PL-South.
-- However, revenue differences between channels within each region were relatively small, indicating broadly balanced channel performance across the regional network.
