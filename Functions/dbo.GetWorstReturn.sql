CREATE FUNCTION [dbo].[GetWorstReturn]
(
	@Ticker nvarchar(10)
)
RETURNS FLOAT
WITH NATIVE_COMPILATION, SCHEMABINDING  
BEGIN ATOMIC WITH  
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,  
    LANGUAGE = N'English'
)  
DECLARE @Return float;

	select TOP 1 @Return=MIN(LOG(dp.Low/dp.[Open])) from pgon.DailySnapShotPricesMemOpt as dp where dp.Ticker=@Ticker

	RETURN @Return
END
