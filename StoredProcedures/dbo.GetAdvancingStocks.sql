CREATE PROCEDURE [dbo].[GetAdvancingStocks]
	@Date as Date,
	@TimeOfDay as DateTime

AS
	DECLARE @PreviousDate AS DATE;
SELECT TOP 1 @PreviousDate= t.[Date] FROM pgon.DailySnapShotPricesMemOpt AS t WHERE t.date<@Date ORDER BY t.Date DESC



SELECT mp.Ticker, ds.[Close] AS PreviousDaysClose,mp.DateTime,mp.[Open], mp.[Close], IsAdvancing = CAST(CASE WHEN mp.[Close]>ds.[Close] THEN 1 ELSE 0 END AS BIT) from pgon.MinutePrice mp
JOIN pgon.DailySnapShotPricesMemOpt ds ON ds.Date=@PreviousDate AND ds.Ticker = mp.Ticker
 WHERE mp.Date=@Date AND mp.DateTime=@TimeOfDay

