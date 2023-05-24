CREATE VIEW [pgon].[Tickers]
	AS SELECT DISTINCT Ticker FROM [pgon].DailySnapshotPrices
