/*
The database must have a MEMORY_OPTIMIZED_DATA filegroup
before the memory optimized object can be created.
*/

CREATE PROCEDURE [pgon].[GetTrendingTickers]
	@Date DATE,
	@PreviousDate DATE=null
as

SELECT  DSP.TICKER,DSP.DATE,DSP.[CLOSE],TA.VWMA10,TA.SMA50,TA.SMA200, TR.Description,TR.Market,TR.MarketCap,TR.Name, TR.SicDescription, TI.[Index]
INTO #TempTable1
FROM PGON.DailySnapshotPricesMEMOPT AS DSP

JOIN PGON.TICKERANALYTICS AS TA ON TA.TICKER=DSP.TICKER AND TA.DATE=DSP.DATE
JOIN SecuritiesAbove1BMarketCap AS S ON S.Ticker=DSP.TICKER
JOIN TickerReference AS TR ON TR.Ticker=DSP.TICKER
LEFT JOIN TickerIndex as TI on TI.Ticker=dsp.Ticker
WHERE DSP.DATE=@Date AND  DSP.[CLOSE]>TA.SMA50 AND DSP.[CLOSE]>TA.VWMA10 AND TA.SMA50>TA.SMA200 AND  DSP.[CLOSE]<35 AND DSP.[CLOSE]>5

IF @PreviousDate is NOT NULL
BEGIN
SELECT  DSP.TICKER,DSP.DATE,DSP.[CLOSE],TA.VWMA10,TA.SMA50,TA.SMA200, TR.Description,TR.Market,TR.MarketCap,TR.Name, TR.SicDescription,TI.[Index]
INTO #TempTable2
FROM PGON.DailySnapshotPricesMEMOPT AS DSP
JOIN PGON.TICKERANALYTICS AS TA ON TA.TICKER=DSP.TICKER AND TA.DATE=DSP.DATE
JOIN SecuritiesAbove1BMarketCap AS S ON S.Ticker=DSP.TICKER
JOIN TickerReference AS TR ON TR.Ticker=DSP.TICKER
LEFT JOIN TickerIndex as TI on TI.Ticker=dsp.Ticker
WHERE DSP.DATE=@PreviousDate AND  DSP.[CLOSE]>TA.SMA50 AND DSP.[CLOSE]>TA.VWMA10 AND TA.SMA50>TA.SMA200 AND  DSP.[CLOSE]<35 AND DSP.[CLOSE]>5

SELECT 
    t.Ticker,
    CASE 
        WHEN tt1.Ticker IS NULL THEN 'DROP'
        WHEN tt1.Ticker IS NOT NULL AND tt2.Ticker IS NULL THEN 'NEW'
        ELSE 'KEEP'
    END AS Status,
    tt2.Ticker AS PreviousTicker
    ,@Date as [Date]
    ,tt1.[Close]
    ,tt1.VWMA10
    ,tt1.SMA50,
    tt1.SMA200
    ,tt1.Description
    ,tt1.Market
    ,tt1.MarketCap
    ,tt1.Name
    ,tt1.SicDescription
    ,tt1.[Index]
    ,eps.Value EPS
    ,fpe.Value FPE
    ,qr.Value QuickRatio
    ,tp.TargetPrice TargetPrice
    ,dvs.MarketCap
    ,dvs.PercentAboveAvg
FROM
(
    SELECT Ticker FROM #TempTable1
    UNION
    SELECT Ticker FROM #TempTable2
) t
LEFT JOIN #TempTable1 AS tt1 ON tt1.Ticker = t.Ticker
LEFT JOIN #TempTable2 AS tt2 ON tt2.Ticker = t.Ticker
LEFT JOIN dbo.EPS as eps on eps.Ticker=t.Ticker
LEFT JOIN dbo.ForwardPE as fpe on fpe.Ticker=t.Ticker
LEFT JOIN dbo.QuickRatio as qr on qr.Ticker=t.Ticker
LEFT JOIN dbo.TargetPrice as tp on tp.Ticker=t.Ticker
LEFT JOIN dbo.DailyVolumeSpikes as dvs on tp.Ticker=dvs.Ticker and dvs.Date=tp.Date

end





