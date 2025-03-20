CREATE TABLE [dbo].[FactorFunds]
(
	FundTicker nvarchar(10) not null primary key,
	QualityFactor bit default(0) not null,
	GrowthFactor bit default(0) not null,
	MomentumFactor bit default(0) not null,
	SizeFactor bit default(0) not null,
	ValueFactor bit default(0) not null,
	VolFactor bit default(0) not null,
	LowVolFactor bit default(0) not null,
	HighDividendFactor bit default(0) not null, 
    [DividendFactor] BIT NOT NULL DEFAULT (0), 
    [LowInterestRateFactor] BIT NOT NULL DEFAULT (0), 
    [BuyBackAchieversFactor] BIT NOT NULL DEFAULT (0),
	[BloombergPricingPowerFactor] BIT NOT NULL DEFAULT (0),
	[BloombergAnalystRatingImproverFactor] BIT NOT NULL DEFAULT(0)
)
