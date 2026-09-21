/* ============================================================
   01_create_warehouse_schema.sql
   Creates the AdventureWorksDW database and star schema
   (Internet Sales only) for the MSBI portfolio project.
   Run this in SSMS while connected to localhost.
   ============================================================ */

-- Step 1: Create the warehouse database
USE master;
GO

IF DB_ID('AdventureWorksDW') IS NULL
BEGIN
    CREATE DATABASE AdventureWorksDW;
END
GO

USE AdventureWorksDW;
GO

-- Step 2: Dimension tables

CREATE TABLE dbo.DimDate (
    DateKey        INT         NOT NULL PRIMARY KEY,   -- format YYYYMMDD
    FullDate       DATE        NOT NULL,
    DayOfMonth     TINYINT     NOT NULL,
    DayName        VARCHAR(10) NOT NULL,
    DayOfWeek      TINYINT     NOT NULL,                -- 1 = Sunday ... 7 = Saturday
    WeekOfYear     TINYINT     NOT NULL,
    MonthName      VARCHAR(10) NOT NULL,
    MonthOfYear    TINYINT     NOT NULL,
    Quarter        TINYINT     NOT NULL,
    Year           SMALLINT    NOT NULL,
    IsWeekend      BIT         NOT NULL
);
GO

CREATE TABLE dbo.DimCustomer (
    CustomerKey     INT IDENTITY(1,1) PRIMARY KEY,   -- surrogate key
    CustomerID      INT          NOT NULL,            -- natural key from source system
    FirstName       NVARCHAR(50) NULL,
    LastName        NVARCHAR(50) NULL,
    EmailAddress    NVARCHAR(50) NULL,
    City            NVARCHAR(30) NULL,
    StateProvince   NVARCHAR(50) NULL,
    CountryRegion   NVARCHAR(50) NULL,
    PostalCode      NVARCHAR(15) NULL
);
GO

CREATE TABLE dbo.DimProduct (
    ProductKey          INT IDENTITY(1,1) PRIMARY KEY,
    ProductID           INT           NOT NULL,
    ProductName         NVARCHAR(50)  NULL,
    ProductCategory     NVARCHAR(50)  NULL,
    ProductSubcategory  NVARCHAR(50)  NULL,
    Color               NVARCHAR(15)  NULL,
    ListPrice           MONEY         NULL,
    StandardCost        MONEY         NULL
);
GO

CREATE TABLE dbo.DimSalesTerritory (
    SalesTerritoryKey  INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID        INT          NOT NULL,
    TerritoryName      NVARCHAR(50) NULL,
    TerritoryGroup     NVARCHAR(50) NULL,
    TerritoryCountry   NVARCHAR(50) NULL
);
GO

-- Step 3: Fact table

CREATE TABLE dbo.FactInternetSales (
    SalesOrderKey         INT IDENTITY(1,1) PRIMARY KEY,
    OrderDateKey          INT NOT NULL REFERENCES dbo.DimDate(DateKey),
    DueDateKey            INT NULL     REFERENCES dbo.DimDate(DateKey),
    ShipDateKey           INT NULL     REFERENCES dbo.DimDate(DateKey),
    CustomerKey           INT NOT NULL REFERENCES dbo.DimCustomer(CustomerKey),
    ProductKey            INT NOT NULL REFERENCES dbo.DimProduct(ProductKey),
    SalesTerritoryKey     INT NULL     REFERENCES dbo.DimSalesTerritory(SalesTerritoryKey),
    SalesOrderNumber      NVARCHAR(20) NULL,
    SalesOrderLineNumber  TINYINT      NULL,
    OrderQuantity         SMALLINT     NULL,
    UnitPrice             MONEY        NULL,
    UnitPriceDiscount     FLOAT        NULL,
    SalesAmount           MONEY        NULL,
    TaxAmt                MONEY        NULL,
    Freight               MONEY        NULL
);
GO

-- Step 4: Helpful indexes for reporting performance (SSAS/Power BI will thank you)

CREATE INDEX IX_FactInternetSales_OrderDateKey ON dbo.FactInternetSales(OrderDateKey);
CREATE INDEX IX_FactInternetSales_CustomerKey  ON dbo.FactInternetSales(CustomerKey);
CREATE INDEX IX_FactInternetSales_ProductKey   ON dbo.FactInternetSales(ProductKey);
GO

PRINT 'AdventureWorksDW schema created successfully.';