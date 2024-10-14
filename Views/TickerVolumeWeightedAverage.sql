CREATE VIEW pgon.TickerVolumeWeightedAverage
AS 
SELECT dsp.Ticker,
dsp.Date,
AVG(dsp.VolumeWeighted) OVER (PARTITION BY dsp.Ticker ORDER BY dsp.Date ROWS BETWEEN 10 PRECEDING and 1 PRECEDING) VMA10
from pgon.DailySnapShotPricesMemOpt as dsp