CREATE  FUNCTION dbo.Hour_1_Gainers
(
    @TradeDate  date,
    @FirstTime  time(0) = '13:30',  -- anchor minute (e.g., 13:30)
    @SecondTime time(0) = '14:30',  -- comparison minute (e.g., 14:30)
    @MinOpen    decimal(19,4) = 5   -- filter: Open > @MinOpen
)
RETURNS TABLE
AS
RETURN
WITH Params AS (
    SELECT
        FirstStart  = datetimefromparts(year(@TradeDate), month(@TradeDate), day(@TradeDate),
                                        datepart(hour,@FirstTime), datepart(minute,@FirstTime), 0, 0),
        SecondStart = datetimefromparts(year(@TradeDate), month(@TradeDate), day(@TradeDate),
                                        datepart(hour,@SecondTime), datepart(minute,@SecondTime), 0, 0)
),
CTE_MinutePrice AS (
    SELECT mp.*
    FROM pgon.MinutePrice AS mp
    CROSS JOIN Params p
    WHERE mp.[Date] = @TradeDate
      AND mp.[Open] > @MinOpen
      AND mp.[DateTime] >= p.FirstStart
      AND mp.[DateTime] <  DATEADD(minute, 1, p.FirstStart)  -- 1-minute window
)
SELECT
    c.Ticker,
    c.[Date],
    c.[DateTime],
    c.Volume,
    c.[Open],
    c.[Close]      AS MinuteClose,
    c.High,
    c.Low,
    c.Transactions,
    mp2.Volume     AS Volume_2,
    mp2.[Open]     AS NextHourOpen,
    d.[Close]      AS DailyClose,
    mp2.[DateTime] AS NextHourDateTime,
    LOG(mp2.[Open] / c.[Open]) AS HR_1_return,     -- natural log return
    d.[Return]     AS EOD_RETURN,
    LOG(d.[Close]/mp2.[Open]) AS My_Return
FROM CTE_MinutePrice AS c
CROSS JOIN Params p
JOIN pgon.MinutePrice AS mp2
  ON mp2.Ticker    = c.Ticker
 AND mp2.[Date]    = c.[Date]
 AND mp2.[DateTime] >= p.SecondStart
 AND mp2.[DateTime] <  DATEADD(minute, 1, p.SecondStart)
JOIN pgon.DailySnapShotPricesMemOpt AS d
  ON d.[Date] = c.[Date]
 AND d.Ticker = c.Ticker
JOIN TickerReference tr on tr.Ticker=c.Ticker

GO
