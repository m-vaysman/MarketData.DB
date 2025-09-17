CREATE FUNCTION fn_GetTTMEarningsPerShare
(
    @Ticker VARCHAR(20)
)
RETURNS TABLE
AS
RETURN
WITH EarningsPerShare AS (
    SELECT 
        Ticker,
        DataPoint,
        FiscalPeriod,
        CAST(REPLACE(FiscalPeriod,'Q','') AS INT) AS Qtr,
        FiscalYear,
        TimeFrame,
        Value,
        SUM(Value) OVER (
            PARTITION BY Ticker 
            ORDER BY FiscalYear, FiscalPeriod 
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS TTM_EPS
    FROM FinancialData
),
EarningPerShareWithDates AS (
    SELECT 
        eps.Ticker,
        eps.DataPoint,
        eps.FiscalPeriod,
        eps.Qtr,
        eps.FiscalYear,
        eps.TimeFrame,
        eps.Value,
        eps.TTM_EPS,
        dt.DateID,
        dt.Year,
        dt.Month,
        dt.Day,
        dt.Weekday,
        dt.Quarter,
        dt.DayOfYear,
        dt.Week,
        dt.MonthName,
        dt.WeekdayName
    FROM EarningsPerShare eps
    RIGHT JOIN DateTable dt 
        ON dt.Year = eps.FiscalYear AND dt.Quarter = eps.Qtr
    WHERE 
        eps.DataPoint = 'basic_earnings_per_share'
        AND dt.DateID < CAST(GETDATE() AS DATE)
        AND eps.Ticker IS NOT NULL
),
StockPE AS (
    SELECT 
        epsd.Ticker,
        epsd.DataPoint,
        epsd.FiscalPeriod,
        epsd.Qtr,
        epsd.FiscalYear,
        epsd.TimeFrame,
        epsd.Value,
        epsd.TTM_EPS,
        dsp.[Close],
        CASE 
            WHEN epsd.TTM_EPS <> 0 THEN dsp.[Close] / epsd.TTM_EPS
            ELSE NULL
        END AS PE,
        epsd.DateID,
        dsp.Volume,
        dsp.VolumeWeighted
    FROM EarningPerShareWithDates epsd
    JOIN pgon.DailySnapshotPricesMemOpt dsp 
        ON dsp.Ticker = epsd.Ticker AND dsp.Date = epsd.DateID
    WHERE epsd.Ticker = @Ticker
)
SELECT * FROM StockPE;
