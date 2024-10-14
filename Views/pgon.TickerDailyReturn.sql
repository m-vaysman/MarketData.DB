CREATE VIEW [pgon].[TickerDailyReturn]
	AS 

	SELECT dp.Ticker, dp.[Date], dp.[Close],
	  coalesce( LOG(dp.High / dp.Low),0) as MaxDailyReturn,
	  coalesce( LOG(dp.Low / dp.High),0) as MinDailyReturn,
      coalesce( LOG(dp.[Close] / LAG(dp.[Close]) OVER (partition by ticker ORDER BY dp.Date)),0) AS DailyReturn
	
FROM pgon.DailySnapShotPricesMemOpt as dp

GO


