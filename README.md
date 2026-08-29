# FMCG Sales Analysis

## Project Overview

This project analyses FMCG sales data from 2022 to 2024 to evaluate sales performance, product mix, channel and regional performance, promotion effectiveness, and inventory indicators.

The analysis was conducted in Google BigQuery using SQL, with a focus on answering practical business questions and identifying measurable performance patterns.

## Business Objectives

The analysis focuses on five main business areas:

- Evaluate overall sales performance and revenue trends over time.
- Identify the strongest-performing product categories and SKUs.
- Compare channel and regional sales performance.
- Assess differences between promoted and non-promoted sales.
- Review inventory and delivery indicators for potential operational issues.

## Dataset

**Source:** Kaggle — FMCG Daily Sales Data 2022–2024

**Analysis period:** 21 January 2022 to 31 December 2024

**Records:** 190,757

**Products:** 30 SKUs

**Confirmed grain:** One record per date, SKU, channel and region.

The dataset includes product, pricing, sales, promotion, delivery and inventory-related fields.

See [`data/data_dictionary.md`](data/data_dictionary.md) for field definitions and data quality notes.

## Tools

- Google BigQuery
- GoogleSQL
- GitHub

SQL techniques used include:

- Aggregation with `SUM`, `AVG`, `COUNT` and `COUNT(DISTINCT)`
- Conditional aggregation with `CASE WHEN`
- Common Table Expressions (CTEs)
- Window functions
- `LAG()`
- `RANK()`
- Running totals
- Revenue contribution analysis
- Year-over-year and month-over-month growth analysis

## Analysis Approach

### Sales Performance

Revenue was calculated at row level using:

```sql
price_unit * units_sold

## Key Findings

- Total revenue reached approximately **$19.95M** from **3.80M units sold**.
- Yogurt was the largest category, generating approximately **$8.23M** and contributing **41.23%** of total revenue.
- YO-029 was the highest-revenue SKU at approximately **$931.9K**.
- Revenue was almost evenly split across channels: Retail **33.36%**, E-commerce **33.35%**, and Discount **33.29%**.
- Regional revenue was similarly balanced: PL-South **33.41%**, PL-North **33.40%**, and PL-Central **33.19%**.
- Promotion represented only **14.92%** of records but generated approximately **25.57%** of total revenue.
- Average units sold increased from **17.44** without promotion to **34.06** under promotion.
- Milk recorded the highest stock-to-sales ratio at approximately **9.0**, followed by Juice at **8.8**, while Yogurt had the lowest ratio at **7.3**.
- After excluding three anomalous negative-value records, no remaining records showed `units_sold` exceeding `stock_available`.

See [`results/key_findings.md`](results/key_findings.md) for the full findings summary.

## Business Recommendations

- Review inventory efficiency for **Milk and Juice**, which recorded the highest stock-to-sales ratios.
- Continue evaluating promotion strategy, as promoted records showed substantially stronger average sales performance.
- Prioritise high-performing Yogurt SKUs such as **YO-029, YO-005 and YO-012**, which were the top three revenue-generating SKUs.
- Maintain broad channel coverage, as revenue contribution was highly balanced across Retail, E-commerce and Discount.
- Continue monitoring the 2023 product expansion cohort, particularly **YO-020**, which generated the highest cumulative revenue among newly observed SKUs.

## Limitations

- The dataset begins on **21 January 2022**, so 2022 does not represent a complete calendar year.
- The active portfolio increased from **20 SKUs in 2022 to 30 SKUs in 2023**, which affects direct annual comparisons.
- `MIN(date)` was used as the first observed date for each SKU and should not be interpreted as a confirmed official launch date.
- Promotion analysis identifies an association between promotion and stronger observed sales performance but does not establish causation.
- The dataset does not include cost of goods sold, gross margin, marketing spend, customer-level transactions, promotion discount depth, inventory holding cost, safety stock targets or shelf life.
- Profitability and true inventory optimisation therefore cannot be determined from the available data.

## Repository Structure

```text
fmcg-sales-analysis/
├── README.md
├── data/
│   └── data_dictionary.md
├── sql/
│   ├── 01_data_validation.sql
│   ├── 02_data_exploration.sql
│   ├── 03_sales_performance.sql
│   ├── 04_product_analysis.sql
│   ├── 05_channel_region_analysis.sql
│   └── 06_promotion_inventory_analysis.sql
├── results/
│   └── key_findings.md
└── images/
