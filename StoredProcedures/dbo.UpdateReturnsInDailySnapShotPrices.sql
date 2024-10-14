CREATE PROCEDURE [dbo].[UpdateReturnsInDailySnapShotPrices]
	@Date datetime
AS
	update pgon.DailySnapShotPricesMemOpt
SET [Return]=Round(log([close]/[open]),3),
    [Drawdown]=Round(log([low]/[open]),3),
	[Rise]=round(log([high]/[open]),3)
where [Date]=@Date
RETURN 0
