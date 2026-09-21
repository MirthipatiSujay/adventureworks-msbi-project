# AdventureWorks MSBI Portfolio Project

An end-to-end Business Intelligence pipeline built on the AdventureWorks sample dataset, covering the full MSBI stack: SQL Server data warehousing, SSIS ETL, Tabular data modeling, and Power BI reporting.

## Overview

This project simulates a real enterprise BI workflow: extracting transactional sales data from an OLTP source database, transforming and loading it into a dimensional data warehouse, and surfacing it through interactive dashboards for business reporting.

## Architecture

```
AdventureWorks2022 (OLTP source)
        |
        v
   SSIS ETL Package  --->  AdventureWorksDW (Star Schema)
   (AdventureWorks_ETL)         |
                                v
                        Tabular Data Model
                        (relationships + DAX measures)
                                |
                                v
                          Power BI Dashboards
```

## Tech Stack

- **SQL Server 2025** — data warehouse (star schema)
- **SSIS (SQL Server Integration Services)** — ETL pipeline with Lookup transformations for surrogate key resolution
- **Tabular Data Modeling** — relationships and DAX measures
- **Power BI Desktop** — interactive dashboards and reporting

## Data Warehouse Design

A star schema (`AdventureWorksDW`) built from scratch, scoped to Internet Sales:

- **Fact table:** `FactInternetSales` — order-line grain, with measures for quantity, price, tax, and freight
- **Dimension tables:** `DimDate`, `DimCustomer`, `DimProduct`, `DimSalesTerritory`

All dimensions use generated surrogate keys rather than reusing source system IDs, following standard warehouse design practice.

## ETL Pipeline (SSIS)

The `AdventureWorks_ETL` SSIS project extracts data from `AdventureWorks2022` and loads it into the warehouse:

- Dimension loads: OLE DB Source (custom SQL, with joins to denormalize category/subcategory, address, and territory data) → OLE DB Destination
- Fact load: source query joining `SalesOrderHeader`/`SalesOrderDetail`, filtered to internet orders, passed through **three Lookup transformations** to resolve `ProductKey`, `CustomerKey`, and `SalesTerritoryKey` from natural keys before loading into `FactInternetSales`

## Data Model & DAX Measures

Relationships were built between the fact table and all four dimensions, with `DimDate` marked as the official date table to support time-intelligence functions. Key measures:

- `Total Sales` — `SUM(FactInternetSales[SalesAmount])`
- `Order Count` — `DISTINCTCOUNT(FactInternetSales[SalesOrderNumber])`
- `Total Profit` — row-level margin calculation using `SUMX` and `RELATED`
- `Sales YoY %` — year-over-year growth using `SAMEPERIODLASTYEAR`

## Dashboards

Three Power BI report pages:

1. **Sales Performance** — KPI cards, monthly sales trend, category breakdown, year/country slicers
2. **Customer Analysis** — top customer locations, sales by country, order volume
3. **Product Performance** — top 10 products, category/subcategory treemap, profit by category

## Files in this Repository

| File / Folder | Description |
|---|---|
| `AdventureWorks_ETL/` | SSIS project — connection managers and the ETL package |
| `AdventureWorksDW_Dashboard.pdf` | Power BI report file |
| `01_create_warehouse_schema.sql` | Creates the AdventureWorksDW database and star schema |
| `02_populate_dimdate.sql` | Populates the date dimension (2010–2014) |
| `03–05_verify_*.sql` | Row-count/spot-check queries used during development |
| `06_fix_factinternetsales_schema.sql` | Schema correction (widened `SalesOrderLineNumber`) |
| `07_verify_factinternetsales.sql` | Final fact table row-count check |

## Key Learnings

- Designing a star schema with surrogate keys and proper fact/dimension grain
- Building SSIS Lookup-based ETL patterns for surrogate key resolution
- Writing DAX measures involving row context (`SUMX`), relationships (`RELATED`), and time intelligence (`SAMEPERIODLASTYEAR`)
- Diagnosing and resolving real-world data issues: column truncation warnings, data type overflow errors, and NULL handling from denormalized joins
