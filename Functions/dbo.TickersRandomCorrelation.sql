CREATE FUNCTION [dbo].[TickersRandomCorrelation]
(
@TickerA nvarchar(10),
@TickerB nvarchar(10),
@StartDate Date
)
RETURNS FLOAT
AS
BEGIN
DECLARE @Correlation float;
    select @Correlation= dbo.Correlation(a.tickerReturn, b.tickerReturn) from GetRandomTickerDailyReturnsWithRow(@TickerA,@StartDate) a
	join GetRandomTickerDailyReturnsWithRow(@TickerB,@StartDate) b on b.row=a.row
	return @Correlation
END
