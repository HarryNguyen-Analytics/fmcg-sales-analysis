-- =========================================================
-- EXPLORATION 1: BUSINESS DIMENSION DISTRIBUTION
-- Understand the main category, channel and regional structure.
-- =========================================================
-- Product channel
select category, 
  count(*) as total_records,
  count(distinct sku) as total_sku
from `fmcg_sales_analysis.raw_sales`
group by category
order by total_sale desc;

/*
Result:
- Yogurt has the broadest product assortment with 11 SKUs and
  the highest record coverage at 72,707 observations.
- Juice has the narrowest assortment with only 1 SKU and
  6,943 observations.
- Record count represents dataset coverage at the
  date + SKU + channel + region grain, not sales performance.
-> The findings do not represent the best product/seller for each category
*/

-- Sales channel
select channel,
  count(*) as total_records,
  count(distinct sku) as total_sku
from `fmcg_sales_analysis.raw_sales`
group by channel
order by total_sale desc;

/*
Result:
- Record coverage is highly balanced across all three channels.
- Retail, E-commerce and Discount each contain all 30 SKUs.
- This provides a relatively balanced base for later channel
  performance comparisons.
*/

-- Regionals Channel
select region,
  count(*) as total_records,
  count(distinct sku) as total_sku
from `fmcg_sales_analysis.raw_sales`
group by region
order by total_sale desc;

/*
Result:
- Record coverage is also highly balanced across the three regions.
- Each region contains all 30 SKUs.
- No major regional coverage imbalance is visible at this stage.
*/


-- =========================================================
-- EXPLORATION 2: PRODUCT PORTFOLIO BY YEAR
-- Understand whether the product assortment changed over time.
-- =========================================================
select 
  extract(year from date) as year_record,
  count(distinct sku) as total_sku,
  count(distinct brand) as total_brand,
  count(distinct segment) AS total_segments,
  count(distinct category) AS total_categories
from `fmcg_sales_analysis.raw_sales`
group by year_record
order by year_record asc;

/*
Result:
- Product coverage increased from 20 SKUs in 2022 to 30 SKUs
  in 2023.
- Brand coverage increased from 12 to 14 brands.
- Segment coverage increased from 11 to 13 segments.
- The portfolio then remained stable through 2024 with
  30 SKUs, 14 brands, 13 segments and 5 categories.
- The number of categories remained unchanged at 5 throughout
  the observed period.

Interpretation:
The portfolio expanded within the existing category structure
between 2022 and 2023 rather than through the addition of new
categories.
-> The difference can be seen as normal business
*/


-- EXPLORATION 3: FIRST APPEARANCE OF EACH SKU
-- Identify when each SKU first appears in the dataset.
select sku,
  min(date) as first_launch,
  extract(year form min(date)) as first_year_launch
from `fmcg_sales_analysis.raw_sales`
group by sku
order by first_launch asc;
/*
Result:
- 20 SKUs were first observed during 2022.
- 10 additional SKUs were first observed between January
  and May 2023.
- No new SKU first appearances were identified in 2024.
- The full 30-SKU portfolio was established by 26 May 2023.

Interpretation:
The product portfolio expanded during the first half of 2023 and remained stable throughout 2024.
2023 is the year with new product,
Note:
MIN(date) represents the first observed date in the dataset. However, it can be seen as product release date.
*/
