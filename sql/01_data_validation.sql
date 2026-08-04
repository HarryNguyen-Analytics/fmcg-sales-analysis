/*
============================================================
Project: FMCG Sales Analysis
File: 01_data_validation.sql
Purpose:
Validate dataset scope, row grain, completeness,
consistency and numerical validity before business analysis.

SQL dialect: GoogleSQL
Platform: Google BigQuery
============================================================
*/


-- =========================================================
-- TEST 1: DATasET OVERVIEW
-- Confirm dataset size, date coverage and key dimensions.
-- =========================================================

select count(*) as total_rows,
  min(date) as start_date,
  max(date) as end_date,
  count(distinct sku) as total_sku,
  count(distinct brand) as total_brand,
  count(distinct segment) as total_segment,
  count(distinct category) as total_category,
  count(distinct channel) as total_channel,
  count(distinct region) as total_region
from `fmcg_sales_analysis.raw_sales`;

/*
Result:
- 190,757 records
- Date coverage: 2022-01-21 to 2024-12-31
- 30 SKUs
- 14 brands
- 13 segments
- 5 categories
- 3 channels
- 3 regions

Validation note:
The dataset does not contain the first 20 days of 2022.
Full-year comparisons involving 2022 require a like-for-like
date range or an explicit limitation note.
*/


-- =========================================================
-- TEST 2: EXPECTED ROW GRAIN
-- Expected grain:
-- one record per date, SKU, channel and region.
-- =========================================================

select date, sku, channel, region, count(*) as rows_per_day
from `fmcg_sales_analysis.raw_sales`
group by date, sku, channel, region 
having count(*) > 1
order by rows_per_day, date, sku

/*
Result:
0 duplicate grain combinations identified.

Confirmed grain:
One record per date, SKU, channel and region.
*/

-- =========================================================
-- TEST 3: NULL VALUES IN KEY ANALYSIS FIELDS
-- =========================================================

select
  countif(date is null) as null_date,
  countif(sku is null) as null_sku,
  countif(brand is null) as null_brand,
  countif(segment is null) as null_segment,
  countif(category is null) as null_category,
  countif(channel is null) as null_channel,
  countif(region is null) as null_region,
  countif(price_unit is null) as null_price_unit,
  countif(unit_sold is null) as null_unit_sold
  countif(stock_available is null) as null_stock_available
from `fmcg_sales_analysis.raw_sales`;

/*
Result:
No null values were identified in the tested key fields.
*/

-- =========================================================
-- TEST 4: INVALID NUMERICAL AND FLAG VALUES
-- =========================================================
select
  countif(price_unit <= 0) as invalid_price_unit,
  countif(units_sold < 0) as negative_units_sold,
  countif(stock_available < 0) as negative_stock_available,
  countif(delivered_qty < 0) as negative_delivered_qty,
  countif(delivery_days < 0) as negative_delivery_days,
  countif(promotion_flag not in (0, 1)) as invalid_promotion_flag
from `fmcg_sales_analysis.raw_sales`;

/*
Result:
No invalid values were identified in the tested numerical fields.

The promotion flag contains only the expected values:
- 0 = non-promoted
- 1 = promoted
*/
