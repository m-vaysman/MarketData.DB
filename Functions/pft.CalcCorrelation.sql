CREATE FUNCTION [ptf].[CalcCorrelation]
(
	@tickerA varchar(10),
	@tickerB varchar(10),
    @startDate date
)
RETURNS float
AS
BEGIN
	RETURN   (SELECT
    (AVG(r.ticker_a_DailyReturn * r.ticker_b_DailyReturn) - (AVG(r.ticker_a_DailyReturn) * AVG(r.ticker_b_DailyReturn))) / (STDEVP(r.ticker_a_DailyReturn) * STDEVP(r.ticker_b_DailyReturn))
  FROM (SELECT
      a.Date
     ,a.[DailyReturn] ticker_a_DailyReturn
     ,b.[close] ticker_b_DailyReturn
    FROM pgon.TickerDailyReturns AS a
    INNER JOIN [pgon].[TickerDailyReturns] AS b
      ON a.[Date] = b.[Date]
    WHERE a.Ticker = @tickerA
    AND b.Ticker = @tickerB
    AND a.[Date] > @startDate) r)
END
