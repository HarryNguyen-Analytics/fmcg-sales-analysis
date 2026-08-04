# Data Dictionary

## Dataset Overview

The dataset contains daily FMCG sales records covering multiple products, sales channels and regions from January 2022 to December 2024.

**Source:** Kaggle — FMCG Daily Sales Data 2022–2024  
**BigQuery table:** `fmcg_sales_analysis.raw_sales`  
**Confirmed grain:** One record per date, SKU, channel and region.

## Fields

| Field | BigQuery Type | Description |
|---|---|---|
| `date` | DATE | Date associated with the sales record. |
| `sku` | STRING | Unique identifier for an individual product. |
| `brand` | STRING | Brand associated with the SKU. |
| `segment` | STRING | Product segment within the FMCG portfolio. |
| `category` | STRING | High-level product category. |
| `channel` | STRING | Sales channel through which the product was sold. |
| `region` | STRING | Geographic sales region. |
| `pack_type` | STRING | Packaging format associated with the SKU. |
| `price_unit` | FLOAT64 | Selling price per unit. |
| `promotion_flag` | INT64 | Indicates whether the record was associated with a promotion: `1` for promoted and `0` for non-promoted. |
| `delivery_days` | INT64 | Number of days associated with product delivery. |
| `stock_available` | INT64 | Reported quantity of stock available for the record. |
| `delivered_qty` | INT64 | Quantity delivered for the record. |
| `units_sold` | INT64 | Number of product units sold. |

## Calculated Metrics

The following metrics will be calculated during analysis rather than stored in the raw table.

| Metric | Calculation |
|---|---|
| Revenue | `price_unit × units_sold` |
| Sales contribution | Revenue for a group divided by total revenue |
| Year-over-year growth | Percentage change compared with the same period in the previous year |
| Promotion sales uplift | Difference in sales performance between promoted and non-promoted records |
| Stock coverage indicators | Comparison of units sold, delivered quantity and available stock |

## Data Quality Notes

- The dataset contains 190,757 records.
- Data covers 21 January 2022 to 31 December 2024.
- The expected grain was confirmed as one record per date, SKU, channel and region.
- No duplicate grain combinations were identified.
- No null values were identified in the key analysis fields.
- Initial numerical and promotion flag validation returned valid results.
- Because 2022 begins on 21 January, full-year comparisons require a like-for-like date range or an explicit limitation note.
