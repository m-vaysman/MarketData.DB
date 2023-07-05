CREATE VIEW [pgon].[TickersAvgForLifetime]
	AS 
	  select distinct ticker,
  avg([open]) over (partition by ticker) as OpenAvg,
  avg(low) over (partition by ticker) as LowAvg,
  avg(high) over (partition by ticker) as HighAvg,
  avg([close]) over (partition by ticker) as CloseAvg 
  from pgon.DailySnapshotPrices
