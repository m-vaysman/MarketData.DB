CREATE VIEW [pgon].[TickerVolatility]
	AS 
	
  select *
   ,STDEV(dpa.DailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 251 PRECEDING AND CURRENT ROW) AS AnnualVolatility
   ,STDEV(dpa.MaxDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 251 PRECEDING AND CURRENT ROW) AS AnnualMaxVolatility
   ,STDEV(dpa.MinDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 251 PRECEDING AND CURRENT ROW) AS AnnualMinVolatility
   ,STDEV(dpa.DailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 125 PRECEDING AND CURRENT ROW) AS SemiAnnualVolatility
   ,STDEV(dpa.MaxDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 125 PRECEDING AND CURRENT ROW) AS SemiAnnualMaxVolatility
   ,STDEV(dpa.MinDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 125 PRECEDING AND CURRENT ROW) AS SemiAnnualMinVolatility
      ,STDEV(dpa.DailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 62 PRECEDING AND CURRENT ROW) AS QtrAnnualVolatility
   ,STDEV(dpa.MaxDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 62 PRECEDING AND CURRENT ROW) AS QtrAnnualMaxVolatility
   ,STDEV(dpa.MinDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 62 PRECEDING AND CURRENT ROW) AS QtrAnnualMinVolatility
         ,STDEV(dpa.DailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS MthAnnualVolatility
   ,STDEV(dpa.MaxDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS MthAnnualMaxVolatility
   ,STDEV(dpa.MinDailyReturn) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS MthAnnualMinVolatility
   from (
  	SELECT dp.Ticker, dp.[Date], dp.[Close],dp.Low,dp.High,dp.[Open],
	  LOG(dp.High / dp.Low) as MaxDailyReturn,
	  LOG(dp.Low / dp.High) as MinDailyReturn,
      LOG(dp.[Close] / LAG(dp.[Close]) OVER (partition by ticker ORDER BY dp.Date)) AS DailyReturn
FROM pgon.DailySnapshotPrices as dp
) as dpa

	
