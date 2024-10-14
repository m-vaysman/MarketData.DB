create function [ptf].[PortfolioWeights]
(
  @portfolio nvarchar(20)
)
returns @ptfweighttable table
(
  Ptf nvarchar(20)
, Ticker nvarchar(5)
, Weight int not null
, WeightPercent decimal(18,8) not null
)
as
begin
  insert @ptfweighttable
  (
    Ptf
  , Ticker
  , Weight
  , WeightPercent
  )
  select b.Ptf
       , b.Ticker
       , b.Weight
       , cast(b.Weight as decimal(18,8)) / cast(c.PtfTotalWeight as decimal(18,8))WeightPercent
  from ptf.Portfolio b
    join (
      select a.Ptf
           , sum(a.Weight) PtfTotalWeight
      from ptf.Portfolio a
      where a.Ptf = @portfolio
      group by a.Ptf) c
      on c.Ptf = b.Ptf

  return
end