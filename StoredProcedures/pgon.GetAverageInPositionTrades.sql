CREATE PROCEDURE [pgon].[GetAverageInPositionTrades]
	@Ticker nvarchar(10),
	@Date Date
AS
	
    CREATE TABLE #TempStockTrades (
    Ticker NVARCHAR(10),
    Date DATE,
    SMA50 FLOAT
);

insert into #TempStockTrades(Ticker,Date,SMA50)
select dsp.Ticker, dsp.Date, AVG(dsp.[Close]) over (order by dsp.date rows between  50 preceding  and current row ) from pgon.DailySnapShotPricesMemOpt as dsp
where dsp.[Date]> DATEADD(DAY, -60, @Date) and dsp.Ticker=@Ticker;

with StockAccumulation
as (
  select top 50 snp.Ticker
       , snp.[Date]
       , snp.[Open]
       , snp.[Low]
       , snp.[High]
       , snp.[Close]
       , snp.Volume
       ,snp.VolumeWeighted
       , tvwa.VMA10
       , tst.SMA50
       , (snp.[Open] + snp.[Close]) / 2 as OpenCloseAvg
       , (snp.High + snp.Low) / 2 as HighLowAvg
       , avg(snp.[Open]) over (order by snp.Date rows between unbounded preceding and current row) as OpenRunningAvg
       , avg(snp.[Close]) over (order by snp.Date rows between unbounded preceding and current row) as CloseRunningAvg
       , 2 * row_number() over (order by snp.Date) - 1 as RunningIntraDayShareAccumulation
       , 2 * row_number() over (order by snp.Date) as RunningShareAccumulation
       , snp.[Open] + snp.[Close] as TotalDailyCashForShares
  from pgon.DailySnapShotPricesMemOpt as snp
  join DateTable dt on dt.DateID=snp.Date
  join pgon.TickerVolumeWeightedAverage as tvwa on tvwa.ticker=snp.ticker and tvwa.date=snp.date
  left join #TempStockTrades tst on tst.Date=snp.Date and tst.Ticker=snp.Ticker
  where snp.Ticker = @Ticker and snp.Date>@Date and snp.[Open]>tvwa.vma10 and snp.[Open]>tst.SMA50),
CashCalculations
as (
  select sa.Ticker
       , sa.Date
       , sa.[Open]
       , sa.Low
       , sa.High
       , sa.[Close]
       , sa.Volume
       , sa.VolumeWeighted
       , sa.VMA10
       , sa.SMA50
       , sa.OpenCloseAvg
       , sa.HighLowAvg
       , round(sa.OpenRunningAvg, 2) as OpenRunningAvg
       , round(sa.CloseRunningAvg, 2) as CloseRunningAvg
       , sa.RunningIntraDayShareAccumulation
       , sa.RunningShareAccumulation
       , sa.TotalDailyCashForShares
       , sum(sa.TotalDailyCashForShares) over (order by sa.[Date] rows between unbounded preceding and current row) as TotalRunningDailyCashForSharesPosition
       , sum(sa.TotalDailyCashForShares) over (order by sa.[Date] rows between unbounded preceding and current row)-sa.[Close] as TotalRunningIntraDailyCashForSharesPosition

  from StockAccumulation sa),
CostBasisCalculations
as (
  select cc.Ticker
       , cc.Date
       , cc.[Open]
       , cc.Low
       , cc.High
       , cc.[Close]
       , cc.Volume
       , cc.VolumeWeighted
       , cc.VMA10
       , cc.SMA50
       , cc.OpenCloseAvg
       , cc.HighLowAvg
       , cc.OpenRunningAvg
       , cc.CloseRunningAvg
       , cc.RunningIntraDayShareAccumulation
       , cc.RunningShareAccumulation
       , cc.TotalDailyCashForShares
       , cc.TotalRunningDailyCashForSharesPosition
       , cc.TotalRunningIntraDailyCashForSharesPosition
       , (cc.TotalRunningIntraDailyCashForSharesPosition/cc.RunningIntraDayShareAccumulation) as IntraDayCostBasis
       , (cc.TotalRunningDailyCashForSharesPosition/cc.RunningShareAccumulation) as CostBasis
       
  from CashCalculations as cc),
PNLCalculations
as
(
select cbc.Ticker
     , cbc.Date
     , cbc.[Open]
     , cbc.Low
     , cbc.High
     , cbc.[Close]
     , tdr.DailyReturn
     , cbc.Volume
     , cbc.VolumeWeighted
     , cbc.VMA10
     , cbc.SMA50
     , cbc.OpenCloseAvg
     , cbc.HighLowAvg
     , cbc.OpenRunningAvg
     , cbc.CloseRunningAvg
     , cbc.RunningIntraDayShareAccumulation
     , cbc.RunningShareAccumulation
     , cbc.TotalDailyCashForShares
     , cbc.TotalRunningDailyCashForSharesPosition
     , cbc.TotalRunningIntraDailyCashForSharesPosition
     , cbc.IntraDayCostBasis
     , cbc.CostBasis
     , (cbc.Low * cbc.RunningIntraDayShareAccumulation) - cbc.TotalRunningIntraDailyCashForSharesPosition as PnlLow
     , (cbc.High * cbc.RunningIntraDayShareAccumulation ) - cbc.TotalRunningIntraDailyCashForSharesPosition as PnlHigh 
     from CostBasisCalculations as cbc
     join pgon.TickerDailyReturns tdr on tdr.Ticker=cbc.Ticker and tdr.Date=cbc.Date
)
select *
from PNLCalculations




