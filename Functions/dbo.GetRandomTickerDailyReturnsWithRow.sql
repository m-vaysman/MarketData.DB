CREATE FUNCTION [dbo].[GetRandomTickerDailyReturnsWithRow]
(
	@ticker varchar(50),
	@startDate Date
)
RETURNS @returntable TABLE
(
    [row] int,
	tickerReturn float
)
AS
BEGIN
	INSERT @returntable
	SELECT ROW_NUMBER() OVER (ORDER BY a.tickerReturn ) ROW, a.tickerReturn from GetRandomTickerDailyReturns(@ticker,@startDate) a
	RETURN
END
