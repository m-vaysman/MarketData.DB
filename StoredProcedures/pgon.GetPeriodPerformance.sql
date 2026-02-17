CREATE PROCEDURE [pgon].[GetPeriodPerformance]
    @Date    DATE,
    @Ticker  NVARCHAR(50) = NULL

WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'English'
)

    DECLARE @Results AS pgon.PeriodPerformanceResult;

    -- Pre-compute period boundaries for the target date
    DECLARE @TargetYear     INT  = YEAR(@Date);
    DECLARE @TargetMonth    INT  = MONTH(@Date);
    DECLARE @TargetQuarter  INT  = DATEPART(quarter, @Date);

    -- Start-of-period boundaries: the first calendar day of each current period.
    -- The "previous period end" is the last trading day BEFORE these dates.
    DECLARE @StartOfWeek    DATE = DATEADD(day, 1 - DATEPART(weekday, DATEADD(day, @@DATEFIRST - 1, @Date)), @Date);
    DECLARE @StartOfMonth   DATE = DATEFROMPARTS(@TargetYear, @TargetMonth, 1);
    DECLARE @StartOfQuarter DATE = DATEFROMPARTS(@TargetYear, 1 + 3 * (@TargetQuarter - 1), 1);
    DECLARE @StartOfYear    DATE = DATEFROMPARTS(@TargetYear, 1, 1);

    -- Lookback lower bounds (generous windows to find the last trading day)
    DECLARE @WeekLookback    DATE = DATEADD(day, -20, @StartOfWeek);
    DECLARE @MonthLookback   DATE = DATEADD(day, -15, @StartOfMonth);
    DECLARE @QuarterLookback DATE = DATEADD(day, -15, @StartOfQuarter);
    DECLARE @YearLookback    DATE = DATEADD(day, -15, @StartOfYear);

    -- Working variables
    DECLARE @CurTicker       NVARCHAR(50);
    DECLARE @CurClose        FLOAT;
    DECLARE @PrevDate        DATE;
    DECLARE @PrevClose       FLOAT;
    DECLARE @Perf            FLOAT;
    DECLARE @PrevTicker      NVARCHAR(50) = N'';

    IF @Ticker IS NOT NULL
    BEGIN
        ---------------------------------------------------------------
        -- SINGLE TICKER MODE
        ---------------------------------------------------------------
        SELECT @CurClose = d.[Close]
        FROM pgon.DailySnapShotPricesMemOpt AS d
        WHERE d.Ticker = @Ticker AND d.[Date] = @Date;

        IF @CurClose IS NOT NULL
        BEGIN
            -- WEEKLY: find max date in [WeekLookback, StartOfWeek), then point-lookup close
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @Ticker AND d.[Date] >= @WeekLookback AND d.[Date] < @StartOfWeek;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @Ticker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@Ticker, N'Weekly', @Date, @CurClose, @PrevClose, @Perf);

            -- MONTHLY
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @Ticker AND d.[Date] >= @MonthLookback AND d.[Date] < @StartOfMonth;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @Ticker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@Ticker, N'Monthly', @Date, @CurClose, @PrevClose, @Perf);

            -- QUARTERLY
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @Ticker AND d.[Date] >= @QuarterLookback AND d.[Date] < @StartOfQuarter;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @Ticker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@Ticker, N'Quarterly', @Date, @CurClose, @PrevClose, @Perf);

            -- ANNUAL
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @Ticker AND d.[Date] >= @YearLookback AND d.[Date] < @StartOfYear;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @Ticker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@Ticker, N'Annual', @Date, @CurClose, @PrevClose, @Perf);
        END
    END
    ELSE
    BEGIN
        ---------------------------------------------------------------
        -- ALL TICKERS MODE: iterate through tickers that traded on @Date
        ---------------------------------------------------------------
        SELECT @CurTicker = MIN(d.Ticker)
        FROM pgon.DailySnapShotPricesMemOpt AS d
        WHERE d.[Date] = @Date;

        WHILE @CurTicker IS NOT NULL
        BEGIN
            -- Get closing price on target date (hash index point lookup)
            SELECT @CurClose = d.[Close]
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @CurTicker AND d.[Date] = @Date;

            -- WEEKLY
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @CurTicker AND d.[Date] >= @WeekLookback AND d.[Date] < @StartOfWeek;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @CurTicker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@CurTicker, N'Weekly', @Date, @CurClose, @PrevClose, @Perf);

            -- MONTHLY
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @CurTicker AND d.[Date] >= @MonthLookback AND d.[Date] < @StartOfMonth;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @CurTicker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@CurTicker, N'Monthly', @Date, @CurClose, @PrevClose, @Perf);

            -- QUARTERLY
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @CurTicker AND d.[Date] >= @QuarterLookback AND d.[Date] < @StartOfQuarter;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @CurTicker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@CurTicker, N'Quarterly', @Date, @CurClose, @PrevClose, @Perf);

            -- ANNUAL
            SET @PrevDate = NULL;
            SELECT @PrevDate = MAX(d.[Date])
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.Ticker = @CurTicker AND d.[Date] >= @YearLookback AND d.[Date] < @StartOfYear;

            SET @PrevClose = NULL;
            IF @PrevDate IS NOT NULL
                SELECT @PrevClose = d.[Close]
                FROM pgon.DailySnapShotPricesMemOpt AS d
                WHERE d.Ticker = @CurTicker AND d.[Date] = @PrevDate;

            SET @Perf = CASE WHEN @PrevClose IS NOT NULL AND @PrevClose <> 0
                             THEN (@CurClose - @PrevClose) / @PrevClose ELSE 0 END;
            INSERT INTO @Results VALUES (@CurTicker, N'Annual', @Date, @CurClose, @PrevClose, @Perf);

            -- Advance to next ticker alphabetically
            SET @PrevTicker = @CurTicker;
            SET @CurTicker = NULL;

            SELECT @CurTicker = MIN(d.Ticker)
            FROM pgon.DailySnapShotPricesMemOpt AS d
            WHERE d.[Date] = @Date AND d.Ticker > @PrevTicker;
        END
    END

    SELECT Ticker, PeriodType, PeriodEndDate, PeriodEndClose, PreviousPeriodEndClose, Performance
    FROM @Results
    ORDER BY Ticker, PeriodType;

END
GO
