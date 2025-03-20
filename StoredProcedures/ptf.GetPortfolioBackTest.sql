CREATE PROCEDURE [ptf].[GetPortfolioBackTest]
	@ptf nvarchar(20),
	@dollarAmountInvested decimal (18,8)=10000
AS

CREATE TABLE #tempWeights(
Ptf nvarchar(20),
Ticker nvarchar(10),
TradeDate date,
OpenPrice float,
WeightPercent decimal(18,8),
InitialSharesPurchased decimal(18,8)

)

insert into  #tempWeights 
select c.Ptf,c.Ticker, c.TradeDate, c.OpenPrice, c.WeightPercent, (@dollarAmountInvested*c.WeightPercent)/cast(c.OpenPrice as decimal(18,8)) InitialSharesPurchased
from 
(
select a.Ptf, a.Ticker, a.[TradeDate],dbo.GetPrice(a.Ticker,a.[TradeDate], 'open') OpenPrice, b.WeightPercent from ptf.Portfolio a
join (
select a.Ptf,a.Ticker,a.Weight,a.WeightPercent from ptf.PortfolioWeights(@ptf) a) b on b.Ticker=a.Ticker and b.Ptf=a.ptf 
) c


select d.*,tmpw.InitialSharesPurchased, (tmpw.InitialSharesPurchased*d.InitialPrice) InvestedAmount from (
select b.Ticker
     , b.TradeDate
     , b.Ptf
     , b.Weight
     , pw.WeightPercent
     , c.[Open] as InitialPrice
     , a.Date
     , a.[Open]
     , a.[Close]
     , a.High
     , a.Low
     , a.[Return]
     , a.Drawdown
     , a.Rise
from pgon.DailySnapShotPricesMemOpt A
  left join dbo.portfolio b
    on a.Ticker = b.ticker
  left join pgon.DailySnapShotPricesMemOpt c
    on c.Ticker = b.Ticker
      and c.Date = b.TradeDate
  left join ptf.PortfolioWeights(@ptf) pw
    on pw.Ptf = b.Ptf
      and pw.Ticker = b.Ticker
where b.Ptf = @ptf
      and b.ticker = a.ticker
      and a.Date >= b.TradeDate) d
       left join #tempWeights as tmpw on tmpw.Ptf = d.Ptf and tmpw.Ticker=d.Ticker and tmpw.TradeDate=d.TradeDate
order by d.Date

