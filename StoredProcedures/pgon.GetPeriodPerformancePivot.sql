/*
================================================================================
  pgon.GetPeriodPerformancePivot
================================================================================
  Returns rolling period performance for common stocks (Type = 'CS') as a
  single row per ticker with each period type as its own column.

  Uses the same rolling lookback logic as pgon.GetPeriodPerformance but pivoted
  into a columnar layout for easier consumption by screeners and dashboards.

  PARAMETERS:
    @Date   DATE           - The snapshot date. Performance is measured from
                             each lookback date to this date's close.
    @Ticker NVARCHAR(50)   - Optional. If NULL, computes for every ticker that
                             is a member of a major US index (RUT, S&P, DJIA,
                             NDX) per dbo.TickerIndex and traded on @Date.
                             If supplied, computes for that single ticker only.

  OUTPUT COLUMNS:
  ──────────────────────────────────────────────────────────────────────────────
  Ticker          - Stock symbol.
  Date            - The @Date parameter echoed back.
  Close           - Closing price on @Date.

  PerfWeekly      - Rolling 1-week return.
                     Lookback: DATEADD(day, -7, @Date), nearest trading day
                     within a 5-day search window.
                     Decimal value (e.g. 0.05 = +5%, -0.03 = -3%).

  PerfMonthly     - Rolling 1-month return.
                     Lookback: DATEADD(month, -1, @Date).

  PerfQuarterly   - Rolling 3-month return.
                     Lookback: DATEADD(month, -3, @Date).

  PerfAnnual      - Rolling 1-year return.
                     Lookback: DATEADD(year, -1, @Date).

  All performance values use the formula:
    (Close_today - Close_lookback) / Close_lookback

  Each lookback finds the closest trading day on or before the target date
  within a 5-calendar-day search window, using CROSS APPLY TOP 1 against
  the in-memory pgon.DailySnapShotPricesMemOpt table.

  PERFORMANCE NOTES:
  - Four index seeks per ticker (one per period) on the in-memory table.
  - Each seek returns exactly 1 row (TOP 1 within a 5-day window).
  - Filtered to major US index members (RUT, S&P, DJIA, NDX) via dbo.TickerIndex.

  USAGE:
    -- Single ticker
    EXEC pgon.GetPeriodPerformancePivot @Date = '2026-02-10', @Ticker = 'AAPL';

    -- All common stocks
    EXEC pgon.GetPeriodPerformancePivot @Date = '2026-02-10';
================================================================================
*/
CREATE PROCEDURE [pgon].[GetPeriodPerformancePivot]
    @Date    DATE,
    @Ticker  NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Rolling lookback targets
    DECLARE @WeekAgo    DATE = DATEADD(day, -7, @Date);
    DECLARE @MonthAgo   DATE = DATEADD(month, -1, @Date);
    DECLARE @QuarterAgo DATE = DATEADD(month, -3, @Date);
    DECLARE @YearAgo    DATE = DATEADD(year, -1, @Date);

    SELECT
        cp.Ticker,
        @Date AS [Date],
        cp.[Close],

        -- Rolling 1-week return: (today - week_ago) / week_ago
        ROUND(
            CASE WHEN pw.[Close] IS NOT NULL AND pw.[Close] <> 0
                 THEN (cp.[Close] - pw.[Close]) / pw.[Close]
                 ELSE NULL
            END, 4) AS PerfWeekly,

        -- Rolling 1-month return
        ROUND(
            CASE WHEN pm.[Close] IS NOT NULL AND pm.[Close] <> 0
                 THEN (cp.[Close] - pm.[Close]) / pm.[Close]
                 ELSE NULL
            END, 4) AS PerfMonthly,

        -- Rolling 3-month (quarterly) return
        ROUND(
            CASE WHEN pq.[Close] IS NOT NULL AND pq.[Close] <> 0
                 THEN (cp.[Close] - pq.[Close]) / pq.[Close]
                 ELSE NULL
            END, 4) AS PerfQuarterly,

        -- Rolling 1-year (annual) return
        ROUND(
            CASE WHEN py.[Close] IS NOT NULL AND py.[Close] <> 0
                 THEN (cp.[Close] - py.[Close]) / py.[Close]
                 ELSE NULL
            END, 4) AS PerfAnnual

    FROM pgon.DailySnapShotPricesMemOpt cp

    -- Week ago: closest trading day on or before @WeekAgo (5-day search window)
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = cp.Ticker
          AND d.[Date] <= @WeekAgo
          AND d.[Date] >= DATEADD(day, -5, @WeekAgo)
        ORDER BY d.[Date] DESC
    ) pw

    -- Month ago: closest trading day on or before @MonthAgo
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = cp.Ticker
          AND d.[Date] <= @MonthAgo
          AND d.[Date] >= DATEADD(day, -5, @MonthAgo)
        ORDER BY d.[Date] DESC
    ) pm

    -- Quarter ago: closest trading day on or before @QuarterAgo
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = cp.Ticker
          AND d.[Date] <= @QuarterAgo
          AND d.[Date] >= DATEADD(day, -5, @QuarterAgo)
        ORDER BY d.[Date] DESC
    ) pq

    -- Year ago: closest trading day on or before @YearAgo
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = cp.Ticker
          AND d.[Date] <= @YearAgo
          AND d.[Date] >= DATEADD(day, -5, @YearAgo)
        ORDER BY d.[Date] DESC
    ) py

    WHERE cp.[Date] = @Date
      AND (@Ticker IS NULL OR cp.Ticker = @Ticker)
      -- Major US index members only (RUT, S&P, DJIA, NDX)
      AND EXISTS (
          SELECT 1
          FROM dbo.TickerIndex ti
          WHERE ti.Ticker = cp.Ticker
            AND (ti.[Index] LIKE N'%RUT%'
              OR ti.[Index] LIKE N'%S&P%'
              OR ti.[Index] LIKE N'%DJIA%'
              OR ti.[Index] LIKE N'%NDX%')
      )

    ORDER BY cp.Ticker;

END
GO
