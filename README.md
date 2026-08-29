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
