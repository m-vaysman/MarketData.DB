CREATE PROCEDURE [dbo].[LoadVolumeAnalysis]
	
AS
--this proc computes avg volume over last year for securities above 10b in market cap. then insert it into a table. USES CURRENT DATE OF RUN.
insert into dbo.DailyVolumeSpikes
(
  Ticker
, Date
, Volume
, VolumeAvg
, PercentAboveAvg
, MarketCap
)
select d.Ticker,d.Date,d.Volume,d.VolumeAvg as bigint,d.PercentAboveAvg,sam.MarketCap from(
	SELECT dsp.Ticker,dsp.[Date], dsp.Volume,v.VolumeAvg, (dsp.Volume-v.VolumeAvg)/v.VolumeAvg PercentAboveAvg FROM pgon.DailySnapShotPricesMemOpt dsp
	left join (
	 Select b.Ticker, AVG(b.Volume) VolumeAvg from(SELECT a.Ticker,a.Volume FROM pgon.DailySnapShotPricesMemOpt as a
	  where a.Volume>0 and a.Date>dateadd(YEAR,-1,GETDATE())) b
	 group by b.Ticker
	 	) v on v.Ticker=dsp.Ticker) d
		left join SecuritiesAbove1BMarketCap sam on sam.Ticker=d.Ticker
		where  d.Date=cast(GETDATE() as date) and sam.MarketCap>10000000000
		order by d.PercentAboveAvg desc
