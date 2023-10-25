CREATE VIEW [dbo].[SecuritiesAbove1BMarketCap]
	AS 
SELECT
  r.Ticker,r.MarketCap
FROM (SELECT
    tr.Ticker
   ,ds.[Close] * tr.ShareClassSharesOutstanding MarketCap
   ,tr.Type
  FROM TickerReference tr
  JOIN (SELECT
      *
    FROM pgon.DailySnapshotPrices
    WHERE Date = (SELECT
        MAX([Date])
      FROM pgon.DailySnapshotPrices)) AS ds
    ON ds.Ticker = tr.Ticker
  WHERE tr.ListDate < '1/1/2023'
  AND tr.ShareClassFigi IS NOT NULL) AS r
WHERE  r.MarketCap > 1000000000 
