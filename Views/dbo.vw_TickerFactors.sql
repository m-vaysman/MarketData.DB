CREATE VIEW [dbo].[vw_TickerFactors]
	AS 
	select A.HoldingTicker
     , sum(A.MarketValue)    MarketValue
     , sum(A.SharesParValue) Shares
     , avg(A.Weight)         Weight
     , max(B.QualityFactor)  QualityFactor
     , max(b.GrowthFactor)   GrowthFactor
     , max(b.MomentumFactor) MomentumFactor
     , max(b.SizeFactor)     SizeFactor
     , max(b.ValueFactor)    ValueFactor
     , max(b.VolFactor)      VolFactor
     , max(b.LowVolFactor)   LowVolFactor
     , max(b.HighDividendFactor) HighDividendFactor
     ,max(b.DividendFactor) DividendFactor
     ,max(b.LowInterestRateFactor) LowInterestRateFactor
     ,max(b.BuyBackAchieversFactor) BuyBackAchieversFactor
     ,max(b.BloombergPricingPowerFactor) BloombergPricingPowerFactor
     ,max(b.BloombergAnalystRatingImproverFactor) BloombergAnalystRatingImproverFactor
from INVESCOETFHOLDINGS A
  join vw_FACTORFUNDS B
    on B.FundTicker = A.FundTicker
group by A.HoldingTicker
