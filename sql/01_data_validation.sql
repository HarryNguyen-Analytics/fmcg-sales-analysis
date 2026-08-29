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

--UPDATE!!!!! Review records containing negative sales or stock values !!!!!
select 
    date,
    category,
    sku,
    channel,
    regions
    units_sold,
    stock_available
from `fmcg_sales_analysis.raw_sales`
where units_sold < 0 or stock_available < 0 
order by date;
/*
2023-07-26 | SnackBar | SN-028 | Discount | PL-South   | units_sold -3  | stock -2
2023-09-21 | SnackBar | SN-010 | Retail   | PL-Central | units_sold -25 | stock -12
2024-03-14 | ReadyMeal| RE-007 | Discount | PL-Central | units_sold -8  | stock -6
*/
-- Result:
-- Three records contained negative values in both units_sold and stock_available.
-- Because the dataset does not provide sufficient information to determine whether these values represent returns, inventory adjustments, or data-entry issues
-- they were flagged as anomalies and excluded from inventory-pressure analysis.


-- =========================================================
-- TEST 5: PRODUCT HIERARCHY CONSISTENCY
-- Each SKU should map to one brand, segment, category
-- and pack type.
-- =========================================================

select sku,
  count(distinct brand) as brand_count,
  count(distinct segment) AS segment_count,
  count(distinct category) AS category_count,
  count(distinct pack_type) AS pack_type_count
from `fmcg_sales_analysis.raw_sales`
group by sku
having count(distinct(brand) > 1
  or count(distinct segment) > 1
  or count(distinct category) > 1
  or count(distinct pack_type) > 1
order by sku

/*
Result:
Each sku will belong unique brand - category - pack_type
*/
  
-- =========================================================
-- TEST 6: EXACT DUPLICATE ROWS
-- Checks whether completely identical records appear
-- more than once.
-- =========================================================
select *, count(*) AS duplicate_count
FROM `fmcg_sales_analysis.raw_sales`
GROUP BY ALL
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;

/*
Result:
There is no data to display. Because no dulicated data in dataset
*/

-- =========================================================
-- TEST 7: SEGMENT TO CATEGORY CONSISTENCY
-- Each segment should belong to one category.
-- =========================================================
select segment, count(distinct category) as ctg_count
from `fmcg_sales_analysis.raw_sales`
group by segment
having count(distinct category) > 1
order by ctg_count desc;


/*
Result:
There is no data to display because each sku is belonged to unique category
*/


-- =========================================================
-- TEST 8: PROMOTION DISTRIBUTION
-- Review the proportion of promoted and non-promoted rows.
-- =========================================================
select
    promotion_flag,
    count(*) AS total_rows,
    round(
          100 * count(*) / sum(count(*)) OVER (),
        2
    ) as row_percentage
from `fmcg_sales_analysis.raw_sales`
group by promotion_flag
 by promotion_flag;

/* Result:
  The propotion of promoted and non-promoted are displayed with proper percentage
*/

-- =========================================================
-- TEST 9: NUMERICAL RANGES
-- Review minimum and maximum values for key measures.
-- =========================================================

select
    min(price_unit) AS min_price_unit,
    max(price_unit) AS max_price_unit,
    min(delivery_days) AS min_delivery_days,
    max(delivery_days) AS max_delivery_days,
    min(stock_available) AS min_stock_available,
    max(stock_available) AS max_stock_available,
    min(delivered_qty) AS min_delivered_qty,
    max(delivered_qty) AS max_delivered_qty,
    min(units_sold) AS min_units_sold,
    max(units_sold) AS max_units_sold
from `fmcg_sales_analysis.raw_sales`;


-- =========================================================
-- TEST 10: ZERO VALUES
-- Zero values are not automatically errors, but should
-- be quantified before analysis.
-- =========================================================

select
    countif(units_sold = 0) AS zero_units_sold,
    countif(stock_available = 0) AS zero_stock_available,
    countif(delivered_qty = 0) AS zero_delivered_qty,
    countif(delivery_days = 0) AS zero_delivery_days
from `fmcg_sales_analysis.raw_sales`;

-- =========================================================
-- TEST 11: DATE CONTINUITY
-- Compare observed dates against the full calendar range.
-- =========================================================
select 
  count(distinct date) as distinct_dates,
  date_diff(max(date), min(date), day) + 1 as expected_calendar,
  date_diff(max(date),min(date), day) + 1 - count(distinct date) as missing_date
from `fmcg_sales_analysis.raw_sales`;

/*Result:
  The final result of distinct_date should be equaled to expected_date. If the distinct_date < expteced_date then missing_date = expected - actual
*/

-- =========================================================
-- TEST 12: YEARLY DATA COVERAGE
-- Confirm coverage and record volume for each year.
-- =========================================================
select
  extract(year from date) as sales_year
  min(date) as first_date, max(date) as last_date,
  count(distinct date) as active_dates,
  count(*) as total_rows,
from `fmcg_sales_analysis.raw_sales`
group by sales_year
order by sales_year acs ;
/*Result:
Each year with start_date - last_date - active date between start and last and their rows
*/


-- =========================================================
-- TEST 13: PRODUCT PORTFOLIO BY YEAR
-- Identify changes in SKU and brand coverage.
-- =========================================================
select 
  extract(year from date) as sales_year,
  count(distinct sku) as total_sku,
  count(distinct brand) as total_brand,
  count(distinct segment) as total_segment,
  count(distinct category) as total_category,
from `fmcg_sales_analysis.raw_sales`
group by sales_year,
order by sales_year asc;


-- =========================================================
-- TEST 14: SKU MARKET COVERAGE
-- Identify products not represented across all channels
-- or all regions.
-- =========================================================
select 
  sku,
  count(distinct channel) as channel_count
  count(distinct region) as region_count
from `fmcg_sales_analysis.raw_sales`
group by sku
having count(distinct channel) < 3 or count(distinct region) < 3
order by channel_count, region_count, sku

/* Result: All SKUs are distributed across all 3 channels and 3 regions. */
