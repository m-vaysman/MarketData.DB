CREATE VIEW [dbo].[vw_FactorFunds]
AS
SELECT
    FundTicker,
    CAST(QualityFactor AS INT) AS QualityFactor,
    CAST(GrowthFactor AS INT) AS GrowthFactor,
    CAST(MomentumFactor AS INT) AS MomentumFactor,
    CAST(SizeFactor AS INT) AS SizeFactor,
    CAST(ValueFactor AS INT) AS ValueFactor,
    CAST(VolFactor AS INT) AS VolFactor,
    CAST(LowVolFactor AS INT) AS LowVolFactor,
    CAST(HighDividendFactor AS INT) AS HighDividendFactor,
    CAST(DividendFactor AS INT) AS DividendFactor,
    CAST(LowInterestRateFactor AS INT) AS LowInterestRateFactor,
    CAST(BuyBackAchieversFactor AS INT) AS BuyBackAchieversFactor,
    CAST(BloombergPricingPowerFactor AS INT) AS BloombergPricingPowerFactor,
    CAST(BloombergAnalystRatingImproverFactor AS INT) AS BloombergAnalystRatingImproverFactor
FROM
    [dbo].[FactorFunds];