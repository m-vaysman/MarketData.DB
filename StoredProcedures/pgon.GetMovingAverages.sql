/*
================================================================================
  pgon.GetMovingAverages
================================================================================
  Computes a comprehensive technical analysis snapshot for one or all tickers
  on a given date. All calculations use the closing price from
  pgon.DailySnapShotPricesMemOpt (in-memory optimized table).

  PARAMETERS:
    @Date   DATE           - The snapshot date. All metrics are computed as of
                             this date's close.
    @Ticker NVARCHAR(50)   - Optional. If NULL, computes for every ticker that
                             is a member of a major US index (RUT, S&P, DJIA,
                             NDX) per dbo.TickerIndex and traded on @Date.
                             If supplied, computes for that single ticker only
                             (still must be in a qualifying index).

  OUTPUT COLUMNS:
  ──────────────────────────────────────────────────────────────────────────────
  Ticker              - Stock symbol.
  Date                - The @Date parameter echoed back for convenience.
  Close               - Closing price on @Date.

  --- Simple Moving Averages (SMA) ─────────────────────────────────────────────
  SMA5 .. SMA500      - Simple moving average of the closing price over the
                         last N trading days, inclusive of today.
                         E.g. SMA20 = average of the 20 most recent closes
                         up to and including @Date.

  --- Price Distance from SMA ──────────────────────────────────────────────────
  PctAboveSMA5 ..     - How far today's close is above (or below) each SMA,
  PctAboveSMA500        expressed as a percentage.
                         Formula: (Close - SMA_N) / SMA_N * 100
                         Positive = price above the average (bullish).
                         Negative = price below the average (bearish).

  --- SMA Cross Detection ──────────────────────────────────────────────────────
  SMA50x200Cross      - Detects if the 50-day SMA crossed the 200-day SMA
                         on this specific date by comparing today's SMA50/200
                         against the prior day's SMA50/200.
                           1  = Golden Cross  (SMA50 crossed above SMA200)
                          -1  = Death Cross   (SMA50 crossed below SMA200)
                           0  = No crossover on this date.

  --- SMA Slope / Momentum ────────────────────────────────────────────────────
  SMA20Slope          - Percent change in SMA20 over the last 20 trading days.
  SMA50Slope          - Percent change in SMA50 over the last 20 trading days.
  SMA200Slope         - Percent change in SMA200 over the last 20 trading days.
                         Formula: (SMA_today - SMA_20daysago) / SMA_20daysago * 100
                         Positive = SMA rising (uptrend).
                         Negative = SMA falling (downtrend).
                         Near-zero SMA50Slope after negative values = "flattening
                         after downturn" = potential bottoming signal.

  --- Annualized Rolling Volatility ────────────────────────────────────────────
  Vol5 .. Vol252      - Annualized volatility over the last N trading days,
                         expressed as a percentage.
                         Methodology: STDEV of daily close-to-close log returns
                         (LN(Close_t / Close_{t-1})), then annualized by
                         multiplying by SQRT(252) and scaled to percent (* 100).
                         E.g. Vol20 = 25.00 means 25% annualized volatility
                         over the last 20 trading days.
                         Typical ranges:
                           - Low-vol stock (KO, JNJ):    ~12-20%
                           - Normal stock (AAPL, MSFT):  ~20-35%
                           - High-vol stock (TSLA, NVDA): ~40-80%+

  --- Beta vs SPY ──────────────────────────────────────────────────────────────
  Beta252             - 252-day (1-year) beta relative to SPY.
                         Measures systematic risk / sensitivity to the market.
                         Formula: Cov(stock_returns, SPY_returns)
                                / Var(SPY_returns)
                         using daily log returns over 252 trading days.
                         Both stock and SPY returns are paired by date so that
                         only days where both traded are included.
                         Typical ranges:
                           - Defensive (KO, JNJ):     ~0.5 - 0.8
                           - Market-like (AAPL):       ~1.0 - 1.2
                           - Aggressive (TSLA, NVDA):  ~1.3 - 2.0+
                           - SPY itself:               ~1.0 exactly

  --- Relative Volume ──────────────────────────────────────────────────────────
  RelativeVolume      - Finviz-style relative volume ratio.
                         Formula: Today's Volume / Avg Volume of prior 63 days
                         (63 trading days ~ 3 calendar months, excluding today).
                         Expressed as a ratio:
                           1.00 = trading at normal volume
                           2.50 = trading at 2.5x normal volume (in play)
                           0.40 = very quiet day, 40% of average

  --- SMA Stack Metrics ────────────────────────────────────────────────────────
  WidthPct            - Width of the SMA fan as a % of price.
                         Formula: (Max SMA - Min SMA) / Close * 100
                         Uses SMA10 through SMA400 (10 SMAs).
                         Wide = trending strongly (up or down).
                         Narrow = consolidating / mean-reverting.

  DispersionPct       - Standard deviation of the 10 SMA values (SMA10-SMA400)
                         around their mean, expressed as a % of price.
                         Similar to WidthPct but less sensitive to outliers.
                         Measures how spread out the entire SMA stack is.

  MinAdjacentGapPct   - Smallest gap between any two consecutive SMAs in the
                         stack (SMA10-20, SMA20-50, ... SMA350-400), expressed
                         as a % of price.
                         When this approaches zero, two SMAs are converging --
                         potential crossover or inflection point.

  OrderedFlag         - Perfect monotonic ordering of price + all SMAs.
                         Checks: Close > SMA10 > SMA20 > SMA50 > ... > SMA400
                           1  = Perfectly bullish stack (price above all, all
                                shorter MAs above longer MAs)
                          -1  = Perfectly bearish stack (price below all, all
                                shorter MAs below longer MAs)
                           0  = Mixed / no perfect ordering.

  SmaOrderCheck       - Same as OrderedFlag but ignores the close price.
                         Only checks SMA ordering: SMA10 > SMA20 > ... > SMA400.
                         Useful when price dips below SMA10 temporarily but
                         the underlying SMA structure is still bullishly stacked.
                           1  = Bullish SMA stack
                          -1  = Bearish SMA stack
                           0  = Mixed

  --- Rolling Period Performance ──────────────────────────────────────────────
  PerfWeekly          - Rolling 1-week return (7 calendar days back).
  PerfMonthly         - Rolling 1-month return (DATEADD month -1).
  PerfQuarterly       - Rolling 3-month return (DATEADD month -3).
  PerfAnnual          - Rolling 1-year return (DATEADD year -1).
                         Each uses the closest trading day on or before the
                         target lookback date within a 5-day search window.
                         Expressed as a decimal ratio (0.05 = +5%, -0.03 = -3%).
                         NULL if no trading day found in the lookback window.

  PERFORMANCE NOTES:
  - All data comes from a single CROSS APPLY per ticker into the in-memory
    table (index seek on Ticker+Date, ~500 rows per ticker).
  - SMA, volatility, beta, and volume aggregates are computed in one GROUP BY
    pass over those ~500 rows -- no additional table scans.
  - SPY benchmark returns are pre-fetched once into a temp table (~500 rows)
    and joined by date inside each ticker's CROSS APPLY.
  - The CROSS APPLY on stack metrics is a scalar computation on the already-
    aggregated SMA values, adding negligible cost.
  - Period performance uses 4 OUTER APPLY TOP 1 seeks per ticker on the
    in-memory table, each returning 1 row. Negligible cost.
  - NOTE: pgon.GetBottomingStocks depends on this proc's column layout.
    If columns are added/removed/reordered, update its temp table to match.

  USAGE:
    -- Single ticker
    EXEC pgon.GetMovingAverages @Date = '2026-02-10', @Ticker = 'AAPL';

    -- All tickers for a date
    EXEC pgon.GetMovingAverages @Date = '2026-02-10';
================================================================================
*/
CREATE PROCEDURE [pgon].[GetMovingAverages]
    @Date    DATE,
    @Ticker  NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 700 calendar days covers ~500 trading days with margin for holidays.
    -- This is the furthest back we need for SMA500 + log returns.
    DECLARE @LookbackStart DATE = DATEADD(day, -700, @Date);

    -- Rolling period performance lookback targets
    DECLARE @WeekAgo    DATE = DATEADD(day, -7, @Date);
    DECLARE @MonthAgo   DATE = DATEADD(month, -1, @Date);
    DECLARE @QuarterAgo DATE = DATEADD(month, -3, @Date);
    DECLARE @YearAgo    DATE = DATEADD(year, -1, @Date);

    --------------------------------------------------------------------------
    -- Step 1: Pre-fetch SPY daily log returns into a temp table.
    --         Used later for beta calculation. One index seek, ~500 rows.
    --         LAG(ORDER BY Date ASC) gives the prior day's close, so
    --         LogReturn = LN(Close_today / Close_yesterday).
    --------------------------------------------------------------------------
    CREATE TABLE #BenchmarkReturns (
        [Date]     DATE NOT NULL PRIMARY KEY,
        LogReturn  FLOAT NULL
    );

    INSERT INTO #BenchmarkReturns ([Date], LogReturn)
    SELECT p.[Date], LOG(p.[Close] / NULLIF(p.PrevClose, 0))
    FROM (
        SELECT d.[Date], d.[Close],
               LAG(d.[Close]) OVER (ORDER BY d.[Date] ASC) AS PrevClose
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = 'SPY'
          AND d.[Date] <= @Date
          AND d.[Date] >= @LookbackStart
    ) p;

    --------------------------------------------------------------------------
    -- Step 2: Main query.
    --   Inner subquery (s): Per-ticker aggregation of ~500 rows via CROSS APPLY.
    --     - Conditional AVG for each SMA window
    --     - Conditional STDEV of log returns for each volatility window
    --     - Covariance/variance formula for beta
    --     - AVG of prior 63 days' volume for relative volume
    --   CROSS APPLY (stack): Derived stack metrics from the aggregated SMAs.
    --   Outer SELECT: Final formatting, rounding, and derived ratios.
    --------------------------------------------------------------------------
    SELECT
        s.Ticker,
        @Date AS [Date],
        s.[Close],

        -- Simple Moving Averages: average close over last N trading days
        ROUND(s.SMA5, 2)   AS SMA5,
        ROUND(s.SMA10, 2)  AS SMA10,
        ROUND(s.SMA20, 2)  AS SMA20,
        ROUND(s.SMA50, 2)  AS SMA50,
        ROUND(s.SMA100, 2) AS SMA100,
        ROUND(s.SMA150, 2) AS SMA150,
        ROUND(s.SMA200, 2) AS SMA200,
        ROUND(s.SMA250, 2) AS SMA250,
        ROUND(s.SMA300, 2) AS SMA300,
        ROUND(s.SMA350, 2) AS SMA350,
        ROUND(s.SMA400, 2) AS SMA400,
        ROUND(s.SMA500, 2) AS SMA500,

        -- Price distance from each SMA as a percentage
        -- Positive = above SMA (bullish), Negative = below SMA (bearish)
        ROUND((s.[Close] - s.SMA5)   / NULLIF(s.SMA5, 0)   * 100, 2) AS PctAboveSMA5,
        ROUND((s.[Close] - s.SMA10)  / NULLIF(s.SMA10, 0)  * 100, 2) AS PctAboveSMA10,
        ROUND((s.[Close] - s.SMA20)  / NULLIF(s.SMA20, 0)  * 100, 2) AS PctAboveSMA20,
        ROUND((s.[Close] - s.SMA50)  / NULLIF(s.SMA50, 0)  * 100, 2) AS PctAboveSMA50,
        ROUND((s.[Close] - s.SMA100) / NULLIF(s.SMA100, 0) * 100, 2) AS PctAboveSMA100,
        ROUND((s.[Close] - s.SMA150) / NULLIF(s.SMA150, 0) * 100, 2) AS PctAboveSMA150,
        ROUND((s.[Close] - s.SMA200) / NULLIF(s.SMA200, 0) * 100, 2) AS PctAboveSMA200,
        ROUND((s.[Close] - s.SMA250) / NULLIF(s.SMA250, 0) * 100, 2) AS PctAboveSMA250,
        ROUND((s.[Close] - s.SMA300) / NULLIF(s.SMA300, 0) * 100, 2) AS PctAboveSMA300,
        ROUND((s.[Close] - s.SMA350) / NULLIF(s.SMA350, 0) * 100, 2) AS PctAboveSMA350,
        ROUND((s.[Close] - s.SMA400) / NULLIF(s.SMA400, 0) * 100, 2) AS PctAboveSMA400,
        ROUND((s.[Close] - s.SMA500) / NULLIF(s.SMA500, 0) * 100, 2) AS PctAboveSMA500,

        -- SMA 50/200 cross detection: compares today vs yesterday's SMA50/200
        -- 1 = Golden Cross (SMA50 crossed above SMA200 today)
        -- -1 = Death Cross (SMA50 crossed below SMA200 today)
        -- 0 = No crossover
        CASE
            WHEN s.PrevSMA50 <  s.PrevSMA200 AND s.SMA50 >= s.SMA200 THEN  1
            WHEN s.PrevSMA50 >  s.PrevSMA200 AND s.SMA50 <= s.SMA200 THEN -1
            ELSE 0
        END AS SMA50x200Cross,

        -- SMA slope / momentum: % change in SMA value over the last 20 trading days.
        -- Positive = SMA rising (uptrend), Negative = SMA falling (downtrend).
        -- Near-zero after negative = SMA flattening (potential bottom).
        ROUND((s.SMA20  - s.SMA20_Lag20)  / NULLIF(s.SMA20_Lag20, 0)  * 100, 4) AS SMA20Slope,
        ROUND((s.SMA50  - s.SMA50_Lag20)  / NULLIF(s.SMA50_Lag20, 0)  * 100, 4) AS SMA50Slope,
        ROUND((s.SMA200 - s.SMA200_Lag20) / NULLIF(s.SMA200_Lag20, 0) * 100, 4) AS SMA200Slope,

        -- Annualized rolling volatility (expressed as percentage)
        -- STDEV(daily log returns) * SQRT(252) * 100
        -- E.g. 25.00 = 25% annualized volatility
        ROUND(s.Vol5   * 100, 2) AS Vol5,
        ROUND(s.Vol10  * 100, 2) AS Vol10,
        ROUND(s.Vol20  * 100, 2) AS Vol20,
        ROUND(s.Vol50  * 100, 2) AS Vol50,
        ROUND(s.Vol100 * 100, 2) AS Vol100,
        ROUND(s.Vol200 * 100, 2) AS Vol200,
        ROUND(s.Vol252 * 100, 2) AS Vol252,

        -- 252-day beta vs SPY: Cov(stock, SPY) / Var(SPY)
        -- Uses paired daily log returns (only days both traded)
        ROUND(s.Beta252, 4) AS Beta252,

        -- Relative volume (Finviz-style): today's volume / 3-month avg volume
        -- Prior 63 trading days (~3 calendar months), excludes today
        -- 1.00 = normal, 2.50 = 2.5x average, 0.40 = quiet day
        ROUND(s.TodayVolume / NULLIF(s.AvgVolume63, 0), 2) AS RelativeVolume,

        -- SMA stack width: (highest SMA - lowest SMA) / price * 100
        -- Wide = strong trend, narrow = consolidation
        ROUND(stack.WidthPct, 2) AS WidthPct,

        -- SMA stack dispersion: STDEV of 10 SMA values / price * 100
        -- Like WidthPct but less sensitive to a single outlier SMA
        ROUND(stack.DispersionPct, 2) AS DispersionPct,

        -- Smallest gap between consecutive SMAs / price * 100
        -- Near zero = two adjacent SMAs converging (potential crossover)
        ROUND(stack.MinAdjacentGapPct, 2) AS MinAdjacentGapPct,

        -- Perfect ordering including price:
        --  1 = Close > SMA10 > SMA20 > ... > SMA400 (fully bullish)
        -- -1 = Close < SMA10 < SMA20 < ... < SMA400 (fully bearish)
        --  0 = mixed
        stack.OrderedFlag,

        -- SMA-only ordering (ignores price position):
        --  1 = SMA10 > SMA20 > ... > SMA400 (bullish structure)
        -- -1 = SMA10 < SMA20 < ... < SMA400 (bearish structure)
        --  0 = mixed
        stack.SmaOrderCheck,

        -- Rolling period performance: (today's close - lookback close) / lookback close
        -- Expressed as a decimal ratio (0.05 = +5%, -0.03 = -3%).
        -- Each lookback finds the closest trading day within a 5-day search window.
        ROUND(CASE WHEN pw.[Close] IS NOT NULL AND pw.[Close] <> 0
                   THEN (s.[Close] - pw.[Close]) / pw.[Close]
                   ELSE NULL END, 4) AS PerfWeekly,
        ROUND(CASE WHEN pm.[Close] IS NOT NULL AND pm.[Close] <> 0
                   THEN (s.[Close] - pm.[Close]) / pm.[Close]
                   ELSE NULL END, 4) AS PerfMonthly,
        ROUND(CASE WHEN pq.[Close] IS NOT NULL AND pq.[Close] <> 0
                   THEN (s.[Close] - pq.[Close]) / pq.[Close]
                   ELSE NULL END, 4) AS PerfQuarterly,
        ROUND(CASE WHEN py.[Close] IS NOT NULL AND py.[Close] <> 0
                   THEN (s.[Close] - py.[Close]) / py.[Close]
                   ELSE NULL END, 4) AS PerfAnnual

    FROM (
        ----------------------------------------------------------------------
        -- Per-ticker aggregation: one CROSS APPLY fetches ~500 rows from the
        -- in-memory table, then conditional aggregates compute everything
        -- in a single GROUP BY pass.
        ----------------------------------------------------------------------
        SELECT
            t.Ticker,
            t.[Close],

            -- SMA: average of the N most recent closing prices (rn=1 is today)
            AVG(CASE WHEN prices.rn <=   5 THEN prices.[Close] END) AS SMA5,
            AVG(CASE WHEN prices.rn <=  10 THEN prices.[Close] END) AS SMA10,
            AVG(CASE WHEN prices.rn <=  20 THEN prices.[Close] END) AS SMA20,
            AVG(CASE WHEN prices.rn <=  50 THEN prices.[Close] END) AS SMA50,
            AVG(CASE WHEN prices.rn <= 100 THEN prices.[Close] END) AS SMA100,
            AVG(CASE WHEN prices.rn <= 150 THEN prices.[Close] END) AS SMA150,
            AVG(CASE WHEN prices.rn <= 200 THEN prices.[Close] END) AS SMA200,
            AVG(CASE WHEN prices.rn <= 250 THEN prices.[Close] END) AS SMA250,
            AVG(CASE WHEN prices.rn <= 300 THEN prices.[Close] END) AS SMA300,
            AVG(CASE WHEN prices.rn <= 350 THEN prices.[Close] END) AS SMA350,
            AVG(CASE WHEN prices.rn <= 400 THEN prices.[Close] END) AS SMA400,
            AVG(CASE WHEN prices.rn <= 500 THEN prices.[Close] END) AS SMA500,

            -- Previous day's SMA50/200 for golden/death cross detection.
            -- Shift window by 1 day: rn >= 2 (exclude today) to rn <= 51/201.
            AVG(CASE WHEN prices.rn >= 2 AND prices.rn <=  51 THEN prices.[Close] END) AS PrevSMA50,
            AVG(CASE WHEN prices.rn >= 2 AND prices.rn <= 201 THEN prices.[Close] END) AS PrevSMA200,

            -- SMA values as of 20 trading days ago, for slope/momentum computation.
            -- SMA_N(20 days ago) = AVG(Close) over rn in [21, 20+N].
            -- Used to detect if an SMA is falling, flat, or rising.
            AVG(CASE WHEN prices.rn >= 21 AND prices.rn <=  40 THEN prices.[Close] END) AS SMA20_Lag20,
            AVG(CASE WHEN prices.rn >= 21 AND prices.rn <=  70 THEN prices.[Close] END) AS SMA50_Lag20,
            AVG(CASE WHEN prices.rn >= 21 AND prices.rn <= 220 THEN prices.[Close] END) AS SMA200_Lag20,

            -- Relative volume components.
            -- TodayVolume: today's raw share volume.
            -- AvgVolume63: average daily volume over prior 63 trading days
            --              (rn >= 2 excludes today, rn <= 64 gives 63 days).
            t.[Volume] AS TodayVolume,
            AVG(CASE WHEN prices.rn >= 2 AND prices.rn <= 64 THEN prices.[Volume] END) AS AvgVolume63,

            -- Annualized volatility: STDEV of daily log returns * sqrt(252).
            -- LogReturn = LN(Close_today / Close_yesterday), computed per row
            -- in the CROSS APPLY below. STDEV ignores NULLs (oldest row).
            STDEV(CASE WHEN prices.rn <=   5 THEN prices.LogReturn END) * SQRT(252.0) AS Vol5,
            STDEV(CASE WHEN prices.rn <=  10 THEN prices.LogReturn END) * SQRT(252.0) AS Vol10,
            STDEV(CASE WHEN prices.rn <=  20 THEN prices.LogReturn END) * SQRT(252.0) AS Vol20,
            STDEV(CASE WHEN prices.rn <=  50 THEN prices.LogReturn END) * SQRT(252.0) AS Vol50,
            STDEV(CASE WHEN prices.rn <= 100 THEN prices.LogReturn END) * SQRT(252.0) AS Vol100,
            STDEV(CASE WHEN prices.rn <= 200 THEN prices.LogReturn END) * SQRT(252.0) AS Vol200,
            STDEV(CASE WHEN prices.rn <= 252 THEN prices.LogReturn END) * SQRT(252.0) AS Vol252,

            -- Beta vs SPY (252-day): Cov(stock, SPY) / Var(SPY)
            -- Using algebraic identity to avoid a separate covariance pass:
            --   Cov(X,Y) = E[XY] - E[X]*E[Y]
            --   Var(Y)   = E[Y^2] - E[Y]^2
            -- All four E[] terms filter to rows where BOTH the stock return
            -- AND the SPY return are non-NULL, ensuring all expectations are
            -- computed over the exact same set of paired trading days.
            CASE WHEN
                (AVG(CASE WHEN prices.rn <= 252 AND prices.LogReturn IS NOT NULL AND prices.BenchReturn IS NOT NULL
                          THEN prices.BenchReturn * prices.BenchReturn END)
               - SQUARE(AVG(CASE WHEN prices.rn <= 252 AND prices.LogReturn IS NOT NULL AND prices.BenchReturn IS NOT NULL
                                  THEN prices.BenchReturn END))) <> 0
            THEN
                -- Numerator: Cov(stock, SPY) = E[XY] - E[X]*E[Y]
                (AVG(CASE WHEN prices.rn <= 252 AND prices.LogReturn IS NOT NULL AND prices.BenchReturn IS NOT NULL
                          THEN prices.LogReturn * prices.BenchReturn END)
               - AVG(CASE WHEN prices.rn <= 252 AND prices.LogReturn IS NOT NULL AND prices.BenchReturn IS NOT NULL
                          THEN prices.LogReturn END)
               * AVG(CASE WHEN prices.rn <= 252 AND prices.LogReturn IS NOT NULL AND prices.BenchReturn IS NOT NULL
                          THEN prices.BenchReturn END))
              -- Denominator: Var(SPY) = E[Y^2] - E[Y]^2
              / (AVG(CASE WHEN prices.rn <= 252 AND prices.LogReturn IS NOT NULL AND prices.BenchReturn IS NOT NULL
                          THEN prices.BenchReturn * prices.BenchReturn END)
               - SQUARE(AVG(CASE WHEN prices.rn <= 252 AND prices.LogReturn IS NOT NULL AND prices.BenchReturn IS NOT NULL
                                  THEN prices.BenchReturn END)))
            ELSE NULL
            END AS Beta252

        FROM (
            -- Today's row for each ticker: provides Close and Volume.
            -- Filtered to major US index members (RUT, S&P, DJIA, NDX) via TickerIndex.
            SELECT d.Ticker, d.[Close], d.[Volume]
            FROM pgon.DailySnapShotPricesMemOpt d
            WHERE d.[Date] = @Date
              AND (@Ticker IS NULL OR d.Ticker = @Ticker)
              AND EXISTS (
                  SELECT 1
                  FROM dbo.TickerIndex ti
                  WHERE ti.Ticker = d.Ticker
                    AND (ti.[Index] LIKE N'%RUT%'
                      OR ti.[Index] LIKE N'%S&P%'
                      OR ti.[Index] LIKE N'%DJIA%'
                      OR ti.[Index] LIKE N'%NDX%')
              )
        ) t
        CROSS APPLY (
            ------------------------------------------------------------------
            -- Per-ticker price history: up to ~500 rows from in-memory table.
            -- rn = 1 is today (@Date), rn = 2 is yesterday, etc.
            -- LEAD(ORDER BY Date DESC) gives the older day's close so that
            -- LogReturn = LN(Close / PrevClose) = correct daily return.
            -- BenchReturn = SPY's log return on the same date (for beta).
            ------------------------------------------------------------------
            SELECT
                p.[Close],
                p.[Date],
                p.[Volume],
                p.rn,
                LOG(p.[Close] / NULLIF(p.PrevClose, 0)) AS LogReturn,
                br.LogReturn AS BenchReturn
            FROM (
                SELECT d.[Close],
                       d.[Date],
                       d.[Volume],
                       ROW_NUMBER() OVER (ORDER BY d.[Date] DESC) AS rn,
                       LEAD(d.[Close]) OVER (ORDER BY d.[Date] DESC) AS PrevClose
                FROM pgon.DailySnapShotPricesMemOpt d
                WHERE d.Ticker = t.Ticker
                  AND d.[Date] <= @Date
                  AND d.[Date] >= @LookbackStart
            ) p
            LEFT JOIN #BenchmarkReturns br ON br.[Date] = p.[Date]
        ) prices
        GROUP BY t.Ticker, t.[Close], t.[Volume]
    ) s
    CROSS APPLY (
        --------------------------------------------------------------------------
        -- SMA Stack Metrics: derived from the 10 core SMAs (SMA10 through SMA400).
        -- Computed as scalar expressions on already-aggregated values.
        --------------------------------------------------------------------------
        SELECT
            -- WidthPct: spread of the entire SMA fan as % of price
            (MaxSMA - MinSMA) / NULLIF(s.[Close], 0) * 100 AS WidthPct,

            -- DispersionPct: STDEV of 10 SMA values around their mean, as % of price
            SQRT(
                (  SQUARE(s.SMA10  - MeanSMA) + SQUARE(s.SMA20  - MeanSMA)
                 + SQUARE(s.SMA50  - MeanSMA) + SQUARE(s.SMA100 - MeanSMA)
                 + SQUARE(s.SMA150 - MeanSMA) + SQUARE(s.SMA200 - MeanSMA)
                 + SQUARE(s.SMA250 - MeanSMA) + SQUARE(s.SMA300 - MeanSMA)
                 + SQUARE(s.SMA350 - MeanSMA) + SQUARE(s.SMA400 - MeanSMA)
                ) / 10.0
            ) / NULLIF(s.[Close], 0) * 100 AS DispersionPct,

            -- MinAdjacentGapPct: smallest gap between consecutive SMAs as % of price
            -- Near zero signals two adjacent SMAs converging
            (SELECT MIN(v.Gap) FROM (VALUES
                (ABS(s.SMA20  - s.SMA10)),
                (ABS(s.SMA50  - s.SMA20)),
                (ABS(s.SMA100 - s.SMA50)),
                (ABS(s.SMA150 - s.SMA100)),
                (ABS(s.SMA200 - s.SMA150)),
                (ABS(s.SMA250 - s.SMA200)),
                (ABS(s.SMA300 - s.SMA250)),
                (ABS(s.SMA350 - s.SMA300)),
                (ABS(s.SMA400 - s.SMA350))
            ) AS v(Gap)) / NULLIF(s.[Close], 0) * 100 AS MinAdjacentGapPct,

            -- OrderedFlag: checks if price + all SMAs are perfectly monotonic
            --  1 = Price > SMA10 > SMA20 > ... > SMA400 (fully bullish)
            -- -1 = Price < SMA10 < SMA20 < ... < SMA400 (fully bearish)
            --  0 = mixed ordering
            CASE
                WHEN s.[Close] > s.SMA10  AND s.SMA10  > s.SMA20  AND s.SMA20  > s.SMA50
                 AND s.SMA50   > s.SMA100 AND s.SMA100 > s.SMA150 AND s.SMA150 > s.SMA200
                 AND s.SMA200  > s.SMA250 AND s.SMA250 > s.SMA300 AND s.SMA300 > s.SMA350
                 AND s.SMA350  > s.SMA400
                    THEN 1
                WHEN s.[Close] < s.SMA10  AND s.SMA10  < s.SMA20  AND s.SMA20  < s.SMA50
                 AND s.SMA50   < s.SMA100 AND s.SMA100 < s.SMA150 AND s.SMA150 < s.SMA200
                 AND s.SMA200  < s.SMA250 AND s.SMA250 < s.SMA300 AND s.SMA300 < s.SMA350
                 AND s.SMA350  < s.SMA400
                    THEN -1
                ELSE 0
            END AS OrderedFlag,

            -- SmaOrderCheck: same monotonic check but ignores close price.
            -- Only checks SMA10 > SMA20 > ... > SMA400 ordering.
            -- Useful when price dips below SMA10 temporarily but the
            -- underlying SMA structure remains bullishly stacked.
            --  1 = bullish SMA stack, -1 = bearish SMA stack, 0 = mixed
            CASE
                WHEN s.SMA10  > s.SMA20  AND s.SMA20  > s.SMA50
                 AND s.SMA50  > s.SMA100 AND s.SMA100 > s.SMA150 AND s.SMA150 > s.SMA200
                 AND s.SMA200 > s.SMA250 AND s.SMA250 > s.SMA300 AND s.SMA300 > s.SMA350
                 AND s.SMA350 > s.SMA400
                    THEN 1
                WHEN s.SMA10  < s.SMA20  AND s.SMA20  < s.SMA50
                 AND s.SMA50  < s.SMA100 AND s.SMA100 < s.SMA150 AND s.SMA150 < s.SMA200
                 AND s.SMA200 < s.SMA250 AND s.SMA250 < s.SMA300 AND s.SMA300 < s.SMA350
                 AND s.SMA350 < s.SMA400
                    THEN -1
                ELSE 0
            END AS SmaOrderCheck
        FROM (
            -- Helper: pre-compute mean, max, min of 10 SMA values for stack metrics
            SELECT
                (s.SMA10 + s.SMA20 + s.SMA50 + s.SMA100 + s.SMA150
                 + s.SMA200 + s.SMA250 + s.SMA300 + s.SMA350 + s.SMA400) / 10.0 AS MeanSMA,
                (SELECT MAX(v.Val) FROM (VALUES
                    (s.SMA10),(s.SMA20),(s.SMA50),(s.SMA100),(s.SMA150),
                    (s.SMA200),(s.SMA250),(s.SMA300),(s.SMA350),(s.SMA400)
                ) AS v(Val)) AS MaxSMA,
                (SELECT MIN(v.Val) FROM (VALUES
                    (s.SMA10),(s.SMA20),(s.SMA50),(s.SMA100),(s.SMA150),
                    (s.SMA200),(s.SMA250),(s.SMA300),(s.SMA350),(s.SMA400)
                ) AS v(Val)) AS MinSMA
        ) agg
    ) stack
    --------------------------------------------------------------------------
    -- Period performance: 4 OUTER APPLYs each seek the closest trading day
    -- on or before the lookback date (5-day search window, TOP 1 DESC).
    -- OUTER APPLY returns NULL if no trading day found in the window.
    -- 4 index seeks per ticker on in-memory table, each returning 1 row.
    --------------------------------------------------------------------------
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = s.Ticker
          AND d.[Date] <= @WeekAgo
          AND d.[Date] >= DATEADD(day, -5, @WeekAgo)
        ORDER BY d.[Date] DESC
    ) pw
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = s.Ticker
          AND d.[Date] <= @MonthAgo
          AND d.[Date] >= DATEADD(day, -5, @MonthAgo)
        ORDER BY d.[Date] DESC
    ) pm
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = s.Ticker
          AND d.[Date] <= @QuarterAgo
          AND d.[Date] >= DATEADD(day, -5, @QuarterAgo)
        ORDER BY d.[Date] DESC
    ) pq
    OUTER APPLY (
        SELECT TOP 1 d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = s.Ticker
          AND d.[Date] <= @YearAgo
          AND d.[Date] >= DATEADD(day, -5, @YearAgo)
        ORDER BY d.[Date] DESC
    ) py
    ORDER BY s.Ticker;

    DROP TABLE #BenchmarkReturns;

END
GO
