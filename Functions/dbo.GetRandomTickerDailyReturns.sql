CREATE FUNCTION [dbo].[GetRandomTickerDailyReturns]
(
	@ticker varchar(50),
	@startDate Date
)
RETURNS @returntable TABLE
(
	tickerReturn float
)
AS
BEGIN
	INSERT  @returntable
	SELECT TOP 50 PERCENT a.DailyReturn from pgon.TickerDailyReturns a WHERE a.Ticker=@ticker and a.Date>=@startDate
    ORDER BY a.RandomID
	RETURN
END
