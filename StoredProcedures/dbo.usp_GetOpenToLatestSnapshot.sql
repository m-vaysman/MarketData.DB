CREATE  PROCEDURE dbo.usp_GetOpenToLatestSnapshot
    @Date       date,
    @OpenTime   datetime,  -- e.g. '2025-09-16 13:30:00'
    @LatestTime datetime   -- e.g. '2025-09-16 13:32:00'
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH OpenRows AS (
        SELECT
            mp.Ticker,
            mp.Date,
            mp.DateTime AS OpenDateTime,
            mp.[Open]   AS OpenPrice,
            mp.[High]   AS OpenHigh,
            mp.[Low]    AS OpenLow
        FROM pgon.MinutePrice mp
        WHERE mp.[Date] = @Date
          AND mp.DateTime = @OpenTime
    )
    SELECT
        -- Names chosen to match the Dapper value-tuple element names below
        o.Ticker                         AS Ticker,
        o.OpenDateTime                   AS OpenDateTime,
        o.OpenPrice                      AS OpenPrice,
        o.OpenHigh                       AS OpenHigh,
        o.OpenLow                        AS OpenLow,
        lastRow.DateTime                 AS LatestDateTime,
        lastRow.[Open]                   AS LatestOpen,
        lastRow.[Close]                  AS LatestClose,
        lastRow.[High]                   AS LatestHigh,
        lastRow.[Low]                    AS LatestLow,
        rng.WindowHigh                   AS WindowHigh,
        rng.WindowLow                    AS WindowLow
    FROM OpenRows o
    OUTER APPLY (
        SELECT TOP (1)
            mp2.DateTime, mp2.[Open], mp2.[Close], mp2.[High], mp2.[Low]
        FROM pgon.MinutePrice mp2
        WHERE mp2.Ticker   = o.Ticker
          AND mp2.[Date]   = @Date
          AND mp2.DateTime >= @OpenTime
          AND mp2.DateTime <= @LatestTime
        ORDER BY mp2.DateTime DESC
    ) lastRow
    OUTER APPLY (
        SELECT
            MAX(mp3.[High]) AS WindowHigh,
            MIN(mp3.[Low])  AS WindowLow
        FROM pgon.MinutePrice mp3
        WHERE mp3.Ticker   = o.Ticker
          AND mp3.[Date]   = @Date
          AND mp3.DateTime >= @OpenTime
          AND mp3.DateTime <= @LatestTime
    ) rng
    ORDER BY o.Ticker;
END
GO
