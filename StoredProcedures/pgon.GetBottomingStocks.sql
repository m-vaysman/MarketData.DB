/*
================================================================================
  pgon.GetBottomingStocks
================================================================================
  Screens for stocks exhibiting a "bottoming" pattern — a prior downtrend
  that is now flattening with early signs of recovery.

  Calls pgon.GetMovingAverages internally and filters the result set.

  SCREENING LOGIC:
  1. Prior downtrend     - Quarterly or annual performance is negative.
  2. Below long MA       - Price is trading below the 200-day SMA.
  3. SMA compression     - The SMA stack width is narrow (consolidating).
  4. SMA flattening      - SMA50 slope is near zero (was falling, now stabilizing).
  5. Short-term recovery - Price has reclaimed SMA10 or SMA20.
  6. Weekly momentum     - Weekly performance is non-negative (short-term positive).

  All screening thresholds are parameterized with sensible defaults so
  the user can tune sensitivity.

  PARAMETERS:
    @Date                DATE           - Snapshot date.
    @Ticker              NVARCHAR(50)   - Optional single ticker filter.
    @MaxSMA50Slope       FLOAT          - Max absolute SMA50 slope (default 0.5).
                                          Smaller = stricter flattening.
    @MaxWidthPct         FLOAT          - Max SMA stack width % (default 15.0).
                                          Must be this narrow or less.
    @MinPerfWeekly       FLOAT          - Min weekly performance (default 0.0).
    @MaxPctAboveSMA200   FLOAT          - Max % above SMA200 (default 0.0).
                                          Negative = must be below SMA200.

  OUTPUT:
    All columns from pgon.GetMovingAverages, filtered to bottoming candidates.
    Ordered by ABS(SMA50Slope) ASC (flattest / most recently turned first).

  USAGE:
    -- Default thresholds
    EXEC pgon.GetBottomingStocks @Date = '2026-02-10';

    -- Stricter flattening
    EXEC pgon.GetBottomingStocks @Date = '2026-02-10', @MaxSMA50Slope = 0.25;

    -- Looser SMA width
    EXEC pgon.GetBottomingStocks @Date = '2026-02-10', @MaxWidthPct = 20.0;
================================================================================
*/
CREATE PROCEDURE [pgon].[GetBottomingStocks]
    @Date               DATE,
    @Ticker             NVARCHAR(50)  = NULL,
    @MaxSMA50Slope      FLOAT         = 0.5,
    @MaxWidthPct        FLOAT         = 15.0,
    @MinPerfWeekly      FLOAT         = 0.0,
    @MaxPctAboveSMA200  FLOAT         = 0.0
AS
BEGIN
    SET NOCOUNT ON;

    -- Temp table must exactly match pgon.GetMovingAverages output (48 columns).
    -- If GetMovingAverages columns change, this table must be updated to match.
    CREATE TABLE #MAData (
        Ticker              NVARCHAR(50),
        [Date]              DATE,
        [Close]             FLOAT,
        SMA5                FLOAT,
        SMA10               FLOAT,
        SMA20               FLOAT,
        SMA50               FLOAT,
        SMA100              FLOAT,
        SMA150              FLOAT,
        SMA200              FLOAT,
        SMA250              FLOAT,
        SMA300              FLOAT,
        SMA350              FLOAT,
        SMA400              FLOAT,
        SMA500              FLOAT,
        PctAboveSMA5        FLOAT,
        PctAboveSMA10       FLOAT,
        PctAboveSMA20       FLOAT,
        PctAboveSMA50       FLOAT,
        PctAboveSMA100      FLOAT,
        PctAboveSMA150      FLOAT,
        PctAboveSMA200      FLOAT,
        PctAboveSMA250      FLOAT,
        PctAboveSMA300      FLOAT,
        PctAboveSMA350      FLOAT,
        PctAboveSMA400      FLOAT,
        PctAboveSMA500      FLOAT,
        SMA50x200Cross      INT,
        SMA20Slope          FLOAT,
        SMA50Slope          FLOAT,
        SMA200Slope         FLOAT,
        Vol5                FLOAT,
        Vol10               FLOAT,
        Vol20               FLOAT,
        Vol50               FLOAT,
        Vol100              FLOAT,
        Vol200              FLOAT,
        Vol252              FLOAT,
        Beta252             FLOAT,
        RelativeVolume      FLOAT,
        WidthPct            FLOAT,
        DispersionPct       FLOAT,
        MinAdjacentGapPct   FLOAT,
        OrderedFlag         INT,
        SmaOrderCheck       INT,
        PerfWeekly          FLOAT,
        PerfMonthly         FLOAT,
        PerfQuarterly       FLOAT,
        PerfAnnual          FLOAT
    );

    -- Populate from GetMovingAverages
    INSERT INTO #MAData
    EXEC pgon.GetMovingAverages @Date = @Date, @Ticker = @Ticker;

    -- Apply bottoming screening criteria
    SELECT *
    FROM #MAData
    WHERE
        -- 1. Prior downtrend: quarterly or annual performance is negative
        (PerfQuarterly < 0 OR PerfAnnual < 0)

        -- 2. Price below long-term moving average
        AND PctAboveSMA200 < @MaxPctAboveSMA200

        -- 3. SMA compression: stack width is narrow (consolidation)
        AND WidthPct <= @MaxWidthPct

        -- 4. SMA flattening: SMA50 slope near zero (the key bottoming signal)
        AND ABS(SMA50Slope) <= @MaxSMA50Slope

        -- 5. Short-term recovery: price has risen above short-term MAs
        AND (PctAboveSMA10 > 0 OR PctAboveSMA20 > 0)

        -- 6. Short momentum positive: weekly performance is non-negative
        AND PerfWeekly >= @MinPerfWeekly

    ORDER BY ABS(SMA50Slope) ASC, WidthPct ASC;

    DROP TABLE #MAData;

END
GO
