/* ============================================================
   02_populate_dimdate.sql
   Populates DimDate for 2010-01-01 through 2014-12-31,
   covering the date range used in AdventureWorks sales data.
   Run against AdventureWorksDW in SSMS.
   ============================================================ */

USE AdventureWorksDW;
GO

DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate   DATE = '2014-12-31';

;WITH DateSeries AS (
    SELECT @StartDate AS FullDate
    UNION ALL
    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @EndDate
)
INSERT INTO dbo.DimDate (
    DateKey, FullDate, DayOfMonth, DayName, DayOfWeek,
    WeekOfYear, MonthName, MonthOfYear, Quarter, Year, IsWeekend
)
SELECT
    CONVERT(INT, FORMAT(FullDate, 'yyyyMMdd'))          AS DateKey,
    FullDate,
    DAY(FullDate)                                       AS DayOfMonth,
    DATENAME(WEEKDAY, FullDate)                         AS DayName,
    DATEPART(WEEKDAY, FullDate)                         AS DayOfWeek,
    DATEPART(WEEK, FullDate)                            AS WeekOfYear,
    DATENAME(MONTH, FullDate)                           AS MonthName,
    MONTH(FullDate)                                     AS MonthOfYear,
    DATEPART(QUARTER, FullDate)                         AS Quarter,
    YEAR(FullDate)                                      AS Year,
    CASE WHEN DATEPART(WEEKDAY, FullDate) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
FROM DateSeries
OPTION (MAXRECURSION 0);
GO

PRINT 'DimDate populated: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows.';
SELECT COUNT(*) AS TotalCount, MIN(FullDate) AS EarliestDate, MAX(FullDate) AS LatestDate FROM dbo.DimDate;