CREATE PROCEDURE [pgon].[GetPeriodPerformance]
    @Date    DATE,
    @Ticker  NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Rolling lookback targets: find the closest trading day on or before these dates
    DECLARE @WeekAgo    DATE = DATEADD(day, -7, @Date);
    DECLARE @MonthAgo   DATE = DATEADD(month, -1, @Date);
    DECLARE @QuarterAgo DATE = DATEADD(month, -3, @Date);
    DECLARE @YearAgo    DATE = DATEADD(year, -1, @Date);

    ;WITH CurrentPrices AS (
        SELECT Ticker, [Close]
        FROM pgon.DailySnapShotPricesMemOpt
        WHERE [Date] = @Date
          AND (@Ticker IS NULL OR Ticker = @Ticker)
    ),
    PrevWeek AS (
        SELECT cp.Ticker, d.[Close] AS PrevClose
        FROM CurrentPrices cp
        CROSS APPLY (
            SELECT TOP 1 d2.[Close]
            FROM pgon.DailySnapShotPricesMemOpt d2
            WHERE d2.Ticker = cp.Ticker
              AND d2.[Date] <= @WeekAgo
              AND d2.[Date] >= DATEADD(day, -5, @WeekAgo)
            ORDER BY d2.[Date] DESC
        ) d
    ),
    PrevMonth AS (
        SELECT cp.Ticker, d.[Close] AS PrevClose
        FROM CurrentPrices cp
        CROSS APPLY (
            SELECT TOP 1 d2.[Close]
            FROM pgon.DailySnapShotPricesMemOpt d2
            WHERE d2.Ticker = cp.Ticker
              AND d2.[Date] <= @MonthAgo
              AND d2.[Date] >= DATEADD(day, -5, @MonthAgo)
            ORDER BY d2.[Date] DESC
        ) d
    ),
    PrevQuarter AS (
        SELECT cp.Ticker, d.[Close] AS PrevClose
        FROM CurrentPrices cp
        CROSS APPLY (
            SELECT TOP 1 d2.[Close]
            FROM pgon.DailySnapShotPricesMemOpt d2
            WHERE d2.Ticker = cp.Ticker
              AND d2.[Date] <= @QuarterAgo
              AND d2.[Date] >= DATEADD(day, -5, @QuarterAgo)
            ORDER BY d2.[Date] DESC
        ) d
    ),
    PrevYear AS (
        SELECT cp.Ticker, d.[Close] AS PrevClose
        FROM CurrentPrices cp
        CROSS APPLY (
            SELECT TOP 1 d2.[Close]
            FROM pgon.DailySnapShotPricesMemOpt d2
            WHERE d2.Ticker = cp.Ticker
              AND d2.[Date] <= @YearAgo
              AND d2.[Date] >= DATEADD(day, -5, @YearAgo)
            ORDER BY d2.[Date] DESC
        ) d
    )
    SELECT
        r.Ticker,
        r.PeriodType,
        @Date AS PeriodEndDate,
        r.PeriodEndClose,
        r.PreviousPeriodEndClose,
        CASE WHEN r.PreviousPeriodEndClose IS NOT NULL AND r.PreviousPeriodEndClose <> 0
             THEN (r.PeriodEndClose - r.PreviousPeriodEndClose) / r.PreviousPeriodEndClose
             ELSE 0
        END AS Performance
    FROM (
        SELECT cp.Ticker, N'Weekly' AS PeriodType, cp.[Close] AS PeriodEndClose, pw.PrevClose AS PreviousPeriodEndClose
        FROM CurrentPrices cp LEFT JOIN PrevWeek pw ON cp.Ticker = pw.Ticker
        UNION ALL
        SELECT cp.Ticker, N'Monthly', cp.[Close], pm.PrevClose
        FROM CurrentPrices cp LEFT JOIN PrevMonth pm ON cp.Ticker = pm.Ticker
        UNION ALL
        SELECT cp.Ticker, N'Quarterly', cp.[Close], pq.PrevClose
        FROM CurrentPrices cp LEFT JOIN PrevQuarter pq ON cp.Ticker = pq.Ticker
        UNION ALL
        SELECT cp.Ticker, N'Annual', cp.[Close], py.PrevClose
        FROM CurrentPrices cp LEFT JOIN PrevYear py ON cp.Ticker = py.Ticker
    ) r
    ORDER BY r.Ticker, r.PeriodType;

END
GO
