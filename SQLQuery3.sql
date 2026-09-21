USE AdventureWorksDW;
SELECT COUNT(*) AS TotalRows, MIN(FullDate) AS EarliestDate, MAX(FullDate) AS LatestDate FROM dbo.DimDate;