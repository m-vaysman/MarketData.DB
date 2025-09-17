CREATE PROCEDURE [dbo].[GetAndStoreGoldenCrossCandidates]
	
AS
	  -- Clear existing data
    DELETE FROM dbo.GoldenCrossCandidates;

    -- Insert and return new data
    WITH PriceWithSMA AS (
        SELECT
            Ticker,
            [Date],
            [Close],
            Volume,
            -- 50-day SMA
            (
                SELECT AVG(C2.[Close])
                FROM pgon.DailySnapShotPricesMemOpt C2
                WHERE C2.Ticker = C1.Ticker
                  AND C2.[Date] <= C1.[Date]
                  AND C2.[Date] > DATEADD(DAY, -50, C1.[Date])
            ) AS SMA50,
            -- 200-day SMA
            (
                SELECT AVG(C2.[Close])
                FROM pgon.DailySnapShotPricesMemOpt C2
                WHERE C2.Ticker = C1.Ticker
                  AND C2.[Date] <= C1.[Date]
                  AND C2.[Date] > DATEADD(DAY, -200, C1.[Date])
            ) AS SMA200,
            -- 5-day volume SMA
            (
                SELECT AVG(C2.Volume)
                FROM pgon.DailySnapShotPricesMemOpt C2
                WHERE C2.Ticker = C1.Ticker
                  AND C2.[Date] <= C1.[Date]
                  AND C2.[Date] > DATEADD(DAY, -5, C1.[Date])
            ) AS VolSMA5
        FROM pgon.DailySnapShotPricesMemOpt C1
    ),
    RankedData AS (
        SELECT *,
            LAG(SMA50, 1) OVER (PARTITION BY Ticker ORDER BY [Date]) AS PrevSMA50,
            LAG(SMA200, 1) OVER (PARTITION BY Ticker ORDER BY [Date]) AS PrevSMA200,
            LAG(VolSMA5, 1) OVER (PARTITION BY Ticker ORDER BY [Date]) AS PrevVolSMA5,
            LAG([Close], 1) OVER (PARTITION BY Ticker ORDER BY [Date]) AS PrevClose
        FROM PriceWithSMA
    )
    INSERT INTO dbo.GoldenCrossCandidates (
        Ticker, [Date], [Close], Volume,
        SMA50, SMA200, VolSMA5,
        PrevSMA50, PrevSMA200, PrevVolSMA5, PrevClose
    )
    SELECT
        Ticker, [Date], [Close], Volume,
        SMA50, SMA200, VolSMA5,
        PrevSMA50, PrevSMA200, PrevVolSMA5, PrevClose
    FROM RankedData
    WHERE 
        PrevSMA50 < PrevSMA200
        AND SMA50 >= SMA200
        AND [Close] > PrevClose
        AND VolSMA5 > PrevVolSMA5;

    -- Return result set
    SELECT *
    FROM dbo.GoldenCrossCandidates
    ORDER BY Ticker, [Date];
RETURN 0
