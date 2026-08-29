-- =========================================================
-- 06. PROMOTION & INVENTORY ANALYSIS
-- =========================================================

-- =========================================================
-- Promotion & Inventory Analysis 1
-- How does sales performance differ between promoted
-- and non-promoted sales?
-- =========================================================

select
    promotion_flag,
    couint(*) as total_records,
    sum(units_sold) as total_sold,
    round(sum(price_unit * units_sold), 2) as total_revenue,
    round(avg(units_sold), 2) as avg_units_sold,
    round(avg(price_unit * units_sold), 2) as avg_revenue_per_record
from `fmcg_sales_analysis.raw_sales`
group by promotion_flag
order by promotion_flag;
-- 
/* What I found:
1. Why is non-promotion total revenue higher?
Because non-promotional sales occur far more often:
    No promotion = 162,296 records
    Promotion    =  28,461 records
Non-promotion appears about 5.7 times more frequently.
So even though each non-promotional selling scenario performs less strongly, there are many more of them.

2. What happens when promotion is active?
I would say average performance is much stronger:
    Average units sold:
        No promotion = 17.44
        Promotion    = 34.06
Promotion is associated with about 95.3% higher average unit sales.
Revenue tells the same story:
    Average revenue:
      No promotion = $91.50
      Promotion    = $179.24
Promotion is associated with about 95.9% higher average revenue.
3. So why does promotion still have lower total revenue?
  Total Revenue = How often the scenario occurs × Average revenue when it occurs
Promotion: stronger performance × low frequency
Non-promotion: weaker performance × very high frequency */

/*
Result:
Non-promotional sales generated approximately $14.85M in revenue
across 85.08% of sales records. Promotional sales represented only
14.92% of records but generated approximately $5.10M, or 25.57%
of total revenue.

Average units sold increased from 17.44 without promotion to 34.06
under promotion, while average revenue increased from $91.50
to $179.24 per sales record.
*/

-- =========================================================
-- Promotion & Inventory Analysis 2
-- Which product categories show the strongest sales increase
-- under promotion?
-- =========================================================
with sales_summary as (
select 
  category,
  round(
    avg(
      case
      when promotion_flag = 0 then units_sold
      end),2) as avg_unit_no_promotion,

  round(
    avg(
      case
      when promotion_flag = 1 then units_sold
      end),2) as avg_unit_promotion,

  round(
    avg(
      case
      when promotion_flag = 0 then price_unit * units_sold
      end),2) as avg_revenue_no_promotion,

  round(
    avg(
      case
      when promotion_flag = 1 then price_unit * units_sold
      end),2) as avg_revenue_promotion, 
from `fmcg_sales_analysis.raw_sales`
group by category)

select sm.category , sm.avg_unit_no_promotion, sm.avg_unit_promotion,
sm.avg_revenue_no_promotion, sm.avg_revenue_promotion,
round((sm.avg_unit_promotion - sm.avg_unit_no_promotion)/sm.avg_unit_no_promotion*100,2) as units_promo_difference_pct
from sales_summary sm
/*
Result:
Promoted sales showed stronger average performance across every category.
SnackBar recorded the largest relative increase in average units sold
at 97.18%.

Yogurt recorded the highest absolute promoted performance at
36.64 average units sold and $192.05 average revenue per sales record.
*/

-- =========================================================
-- Promotion & Inventory Analysis 3
-- Which product categories carry the most stock relative to sales?
-- =========================================================

with stock_ratio_summary as(
select 
  category,
  round(avg(units_sold),1) as avg_unit_sold,
  round(avg(stock_available),1) as avg_stock_available
from `fmcg_sales_analysis.raw_sales`
group by category)

select *,
round(sm.avg_stock_available/sm.avg_unit_sold,1) as stock_to_sales_ratio
from stock_ratio_summary sm
order by stock_to_sales_ratio desc;

/*
Result:
Average stock availability was approximately 158 units across categories.

Milk recorded the highest stock-to-sales ratio at approximately 9.0,
followed by Juice at 8.8, while Yogurt had the lowest ratio at 7.3.
This indicates that Milk and Juice carried relatively more stock
compared with their observed sales levels.
*/

-- =========================================================
-- Promotion & Inventory Analysis 4
-- Which product categories have the longest average delivery times?
-- =========================================================
with delivery_summary as (
select 
  category,
  round(avg(delivery_days),2) as avg_delivery_days,
  round(avg(delivered_qty),2) as avg_delivered_qty  
from `fmcg_sales_analysis.raw_sales`
group by category)

select *,
rank() over (order by ds.avg_delivery_days desc) as delivery_time_rank
from delivery_summary ds

/*
Result:
Average delivery performance was highly consistent across categories.
Juice recorded the longest average delivery time at 3.03 days,
while ReadyMeal and Milk averaged approximately 3.00 days.
*/


-- ===================================================================================
-- Promotion & Inventory Analysis 5
-- Which product categories show the highest potential stock pressure?
-- ===================================================================================
    
select 
  category,
  count(*) total_record,
  sum(
  case
    when stock_available < units_sold then 1
    else 0
    end) as stock_presure,

  round(
    sum(
    case
      when stock_available < units_sold then 1
      else 0
      end)/count(*)*100,2) as stock_pressure_pct
  
from `fmcg_sales_analysis.raw_sales`
where units_sold >= 0 and stock_available >=0 -- Where I try to detect more negative values. Those numbers need to be positive to match with the condt stock < sold
group by category
order by stock_pressure_pct desc;
/*
Result:
After excluding three anomalous records containing negative values
in both units_sold and stock_available, no remaining sales records
showed units_sold exceeding stock_available.

Based on this definition, the dataset provides no evidence of
category-level stock pressure.
*/
