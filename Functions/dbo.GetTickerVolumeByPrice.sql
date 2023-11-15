CREATE FUNCTION [dbo].[GetTickerVolumeByPrice]
(
	@ticker varchar(50),
	@startDate Date,
	@endDate Date,
	@roundingPlace int=0
)
RETURNS @returntable TABLE
(
Price decimal(28,4),
Volume float
)
AS
BEGIN
	INSERT @returntable
	SELECT r.Price,
       SUM( r.Volume ) AS v
FROM (SELECT Round(dtsp.Price,@roundingPlace) AS Price,
             dtsv.Volume
  FROM pgon.DailyTimeSeriesPrices dtsp
  JOIN
  pgon.DailyTimeSeriesVolumes dtsv
  ON dtsp.Ticker=dtsv.Ticker
  AND dtsp.TimeStamp=dtsv.TimeStamp
  WHERE dtsp.Ticker=@ticker
        AND dtsp.TimeStamp>@startDate
        AND dtsp.TimeStamp<@endDate) r
GROUP BY r.Price

	RETURN
END
