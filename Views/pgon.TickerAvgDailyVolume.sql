CREATE VIEW [pgon].[TickerAvgDailyVolume]
	AS /****** Script for SelectTopNRows command from SSMS  ******/
select p.Ticker, CONVERT(INT,Avg(p.Volume))  as Volume, COUNT(p.Ticker) DaysInCalculation from pgon.DailySnapshotPrices as p
group by p.Ticker
