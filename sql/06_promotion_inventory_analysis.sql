-- Promotion & Inventory Analysis 1 — Promotion & Inventory Analysis 1 — How does sales performance differ between promoted and non-promoted sales?
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

-- Result:
-- 1. Why is non-promotion total revenue higher?
-- Because non-promotional sales occur far more often:
-- No promotion = 162,296 records
-- Promotion    =  28,461 records
-- Non-promotion appears about 5.7 times more frequently.
-- So even though each non-promotional selling scenario performs less strongly, there are many more of them.

-- 2. What happens when promotion is active?
-- I would say average performance is much stronger:
    -- Average units sold:
        -- No promotion = 17.44
        -- Promotion    = 34.06
-- Promotion is associated with about 95.3% higher average unit sales.
-- Revenue tells the same story:
    -- Average revenue:
      -- No promotion = $91.50
      -- Promotion    = $179.24
-- Promotion is associated with about 95.9% higher average revenue.
-- 3. So why does promotion still have lower total revenue?
  -- Total Revenue = How often the scenario occurs × Average revenue when it occurs
-- Promotion: stronger performance × low frequency
-- Non-promotion: weaker performance × very high frequency

-- Result: Non-promotional sales generated the majority of total revenue because they accounted for 85.08% of sales records.
-- However, when promotion was active, average unit sales increased from 17.44 to 34.06 units and average revenue increased from $91.50 to $179.24 per selling scenario. 
-- Promotion was therefore associated with substantially stronger sales performance when active, although the analysis does not establish causation or profitability.

-- Promotion & Inventory Analysis 2 — Which product categories show the strongest sales performance under promotion?
select *
from fmcg
