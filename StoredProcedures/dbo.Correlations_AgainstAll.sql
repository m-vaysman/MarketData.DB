CREATE  PROCEDURE dbo.Correlations_AgainstAll
    @MainTicker varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    /* T-1 end date for the main ticker */
    DECLARE @EndDate date =
    (
        SELECT DATEADD(DAY, -1, MAX([Date]))
        FROM pgon.DailySnapShotPricesMemOpt
        WHERE Ticker = @MainTicker
    );

    /* The last 252 business dates for the main ticker, ending T-1 */
    WITH MainDates AS
    (
        SELECT  d.[Date],
                rn = ROW_NUMBER() OVER (ORDER BY d.[Date] DESC)
        FROM pgon.DailySnapShotPricesMemOpt d
        WHERE d.Ticker = @MainTicker
          AND d.[Date] <= @EndDate
    ),
    TakeDates AS
    (
        SELECT [Date], rn
        FROM MainDates
        WHERE rn <= 252
    ),
    /* Align returns of main ticker with every other ticker on those dates */
    Base AS
    (
        SELECT  td.rn,
                td.[Date],
                o.Ticker            AS CorrelatedTicker,
                m.[Return]          AS x,    -- main ticker return
                o.[Return]          AS y     -- other ticker return
        FROM TakeDates td
        JOIN pgon.DailySnapShotPricesMemOpt m
              ON m.Ticker = @MainTicker
             AND m.[Date]  = td.[Date]
        LEFT JOIN pgon.DailySnapShotPricesMemOpt o
              ON o.[Date]  = td.[Date]
             AND o.Ticker <> @MainTicker
    ),
    /* Aggregate sums needed for Pearson correlation in each window */
    Agg AS
    (
        SELECT
            CorrelatedTicker,

            /* counts (must equal window to produce a value) */
            cnt5   = SUM(CASE WHEN rn <= 5   AND y IS NOT NULL THEN 1 ELSE 0 END),
            cnt20  = SUM(CASE WHEN rn <= 20  AND y IS NOT NULL THEN 1 ELSE 0 END),
            cnt60  = SUM(CASE WHEN rn <= 60  AND y IS NOT NULL THEN 1 ELSE 0 END),
            cnt120 = SUM(CASE WHEN rn <= 120 AND y IS NOT NULL THEN 1 ELSE 0 END),
            cnt252 = SUM(CASE WHEN rn <= 252 AND y IS NOT NULL THEN 1 ELSE 0 END),

            /* sums for 5 */
            sx5  = SUM(CASE WHEN rn <= 5   THEN x     ELSE 0 END),
            sy5  = SUM(CASE WHEN rn <= 5   THEN y     ELSE 0 END),
            sxx5 = SUM(CASE WHEN rn <= 5   THEN x*x   ELSE 0 END),
            syy5 = SUM(CASE WHEN rn <= 5   THEN y*y   ELSE 0 END),
            sxy5 = SUM(CASE WHEN rn <= 5   THEN x*y   ELSE 0 END),

            /* sums for 20 */
            sx20  = SUM(CASE WHEN rn <= 20  THEN x     ELSE 0 END),
            sy20  = SUM(CASE WHEN rn <= 20  THEN y     ELSE 0 END),
            sxx20 = SUM(CASE WHEN rn <= 20  THEN x*x   ELSE 0 END),
            syy20 = SUM(CASE WHEN rn <= 20  THEN y*y   ELSE 0 END),
            sxy20 = SUM(CASE WHEN rn <= 20  THEN x*y   ELSE 0 END),

            /* sums for 60 */
            sx60  = SUM(CASE WHEN rn <= 60  THEN x     ELSE 0 END),
            sy60  = SUM(CASE WHEN rn <= 60  THEN y     ELSE 0 END),
            sxx60 = SUM(CASE WHEN rn <= 60  THEN x*x   ELSE 0 END),
            syy60 = SUM(CASE WHEN rn <= 60  THEN y*y   ELSE 0 END),
            sxy60 = SUM(CASE WHEN rn <= 60  THEN x*y   ELSE 0 END),

            /* sums for 120 */
            sx120  = SUM(CASE WHEN rn <= 120 THEN x     ELSE 0 END),
            sy120  = SUM(CASE WHEN rn <= 120 THEN y     ELSE 0 END),
            sxx120 = SUM(CASE WHEN rn <= 120 THEN x*x   ELSE 0 END),
            syy120 = SUM(CASE WHEN rn <= 120 THEN y*y   ELSE 0 END),
            sxy120 = SUM(CASE WHEN rn <= 120 THEN x*y   ELSE 0 END),

            /* sums for 252 */
            sx252  = SUM(CASE WHEN rn <= 252 THEN x     ELSE 0 END),
            sy252  = SUM(CASE WHEN rn <= 252 THEN y     ELSE 0 END),
            sxx252 = SUM(CASE WHEN rn <= 252 THEN x*x   ELSE 0 END),
            syy252 = SUM(CASE WHEN rn <= 252 THEN y*y   ELSE 0 END),
            sxy252 = SUM(CASE WHEN rn <= 252 THEN x*y   ELSE 0 END)
        FROM Base
        WHERE CorrelatedTicker IS NOT NULL
        GROUP BY CorrelatedTicker
    )
    SELECT
        MainTicker       = @MainTicker,
        CorrelatedTicker,

        [5 Day Correlation] =
            CASE WHEN cnt5 = 5
                 THEN (5.0 * sxy5 - sx5 * sy5)
                      / NULLIF(SQRT((5.0 * sxx5 - sx5 * sx5) * (5.0 * syy5 - sy5 * sy5)), 0)
            END,

        [20 Day Correlation] =
            CASE WHEN cnt20 = 20
                 THEN (20.0 * sxy20 - sx20 * sy20)
                      / NULLIF(SQRT((20.0 * sxx20 - sx20 * sx20) * (20.0 * syy20 - sy20 * sy20)), 0)
            END,

        [60 Day Correlation] =
            CASE WHEN cnt60 = 60
                 THEN (60.0 * sxy60 - sx60 * sy60)
                      / NULLIF(SQRT((60.0 * sxx60 - sx60 * sx60) * (60.0 * syy60 - sy60 * sy60)), 0)
            END,

        [120 Day Correlation] =
            CASE WHEN cnt120 = 120
                 THEN (120.0 * sxy120 - sx120 * sy120)
                      / NULLIF(SQRT((120.0 * sxx120 - sx120 * sx120) * (120.0 * syy120 - sy120 * sy120)), 0)
            END,

        [252 Day Correlation] =
            CASE WHEN cnt252 = 252
                 THEN (252.0 * sxy252 - sx252 * sy252)
                      / NULLIF(SQRT((252.0 * sxx252 - sx252 * sx252) * (252.0 * syy252 - sy252 * sy252)), 0)
            END
    FROM Agg
    /* keep rows where at least one window has enough data */
    WHERE cnt5 = 5 OR cnt20 = 20 OR cnt60 = 60 OR cnt120 = 120 OR cnt252 = 252
    ORDER BY CorrelatedTicker;
END
GO
