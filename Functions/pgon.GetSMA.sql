CREATE FUNCTION [pgon].[GetSMA]
(
	@Ticker nvarchar(10),
	@Date DATE,
	@SMA int
)
RETURNS float
AS
BEGIN

	DECLARE @RESULT FLOAT
	
DECLARE  @smaDate DATE;
set @smaDate= DATEADD(DAY,-50,@DATE);
	
	SELECT TOP 1 @RESULT=A.SMA FROM(
	SELECT dsp.[date], AVG(dsp.[Close]) over (order by dsp.date ROWS BETWEEN 50 PRECEDING AND CURRENT ROW) SMA
			FROM PGON.DailySnapShotPricesMemOpt AS dsp
			where dsp.ticker=@Ticker) A
			where a.Date=@DATE
			RETURN @RESULT
END;
