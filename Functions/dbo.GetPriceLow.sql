CREATE FUNCTION [dbo].[GetPriceLow]
(
	@ticker varchar(50)
)
RETURNS @highlow TABLE
(
	TimeFrame nvarchar(8) not null,
    Ticker varchar(50) not null,
	Date date not null,
	Low decimal(28,4) not null,
	Measure nvarchar(4) not null
)
AS
BEGIN
    INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
	SELECT TOP 1 'LIFETIME' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE  dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low] asc


INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '2Y' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(year,-2, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '1Y' as TimeFrame,dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(year,-1, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '6M' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(month,-6, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '3M' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(month,-3, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '2M' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(month,-2, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '1M' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(month,-1, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '2W' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(week,-2, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

INSERT INTO @highlow(TimeFrame,Ticker,Date,Low,Measure)
SELECT TOP 1 '1W' as TimeFrame, dsp.Ticker,dsp.Date,dsp.Low,'LOW' as Measure FROM MarketData.pgon.DailySnapshotPrices AS dsp
WHERE dsp.[Date]>=DATEADD(week,-1, GETDATE( )) and dsp.Date<= GETDATE( )  and dsp.ticker =@ticker
order by dsp.[Low]  asc

	RETURN
END
