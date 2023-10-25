CREATE PROCEDURE [pgon].[DeleteNonCapitalizedTickersFromDailySnapshotPrices]
	
AS
DELETE FROM pgon.DailySnapshotPrices
WHERE Ticker COLLATE Latin1_General_BIN <> UPPER(Ticker);

