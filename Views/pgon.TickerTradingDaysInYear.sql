CREATE VIEW [pgon].[TickerTradingDaysInYear]
	AS 
	  select stock.Ticker,stock.YEAR, count(*) TradingDaysInYear from(
  select *, YEAR(date) as [YEAR] from pgon.DailySnapshotPrices  ) as stock
  group by stock.Ticker, stock.YEAR
