CREATE VIEW [pgon].[TickerVolatilityMemOpt]
	AS 
	
  select *
   ,STDEV(dpa.[Return]) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 251 PRECEDING AND CURRENT ROW) AS AnnualStDev
   ,STDEV(dpa.[Return]) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 125 PRECEDING AND CURRENT ROW) AS SemiAnnualStDev
      ,STDEV(dpa.[Return]) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 62 PRECEDING AND CURRENT ROW) AS QtrAnnualStDev
    ,STDEV(dpa.[Return]) OVER (partition by dpa.ticker ORDER BY dpa.Date  ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS MthAnnualStDev
   FROM pgon.DailySnapshotPricesMemOpt as dpa


	
