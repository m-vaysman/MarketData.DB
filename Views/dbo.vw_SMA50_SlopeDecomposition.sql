CREATE VIEW [dbo].[vw_SMA50_SlopeDecomposition]
	AS 

	WITH RankedCloses AS (
    SELECT 
        Ticker,
        [Date],
        [Close],
        ROW_NUMBER() OVER (PARTITION BY Ticker ORDER BY [Date] DESC) AS RN
    FROM pgon.DailySnapShotPricesMemOpt
),
SMA50Decomp AS (
    SELECT 
        Ticker,
        AVG(CASE WHEN RN BETWEEN 1 AND 50 THEN [Close] END) AS SMA50_Latest,
        AVG(CASE WHEN RN BETWEEN 6 AND 55 THEN [Close] END) AS SMA50_5DaysAgo,
        AVG(CASE WHEN RN BETWEEN 1 AND 5 THEN [Close] END) AS New5Avg,
        AVG(CASE WHEN RN BETWEEN 51 AND 55 THEN [Close] END) AS Old5Avg
    FROM RankedCloses
    WHERE RN <= 55
    GROUP BY Ticker
)
SELECT 
    Ticker,
    SMA50_Latest,
    SMA50_5DaysAgo,
    SMA50_Latest - SMA50_5DaysAgo AS SMA50_Change,
    (New5Avg - Old5Avg) / 50.0 AS Contribution,
    CASE 
        WHEN ABS((New5Avg - Old5Avg) / 50.0) > ABS(SMA50_Latest - SMA50_5DaysAgo) * 0.75 THEN 'Organic Rise (Driven by New Data)'
        WHEN ABS((New5Avg - Old5Avg) / 50.0) < ABS(SMA50_Latest - SMA50_5DaysAgo) * 0.25 THEN 'Decay Effect (Old Data Dropped)'
        ELSE 'Mixed Influence'
    END AS SlopeDriver
FROM SMA50Decomp;
