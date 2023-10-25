CREATE TABLE [dbo].[EtfSecurityReference]
(
    FundTicker NVARCHAR(10) NOT NULL PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL,
    SEDOL NVARCHAR(100),
    ISIN NVARCHAR(100) NOT NULL,
    CUSIP NVARCHAR(100) NOT NULL,
    InceptionDate DATE,
    AssetClass NVARCHAR(100),
    SubAssetClass NVARCHAR(100),
    [Region] NVARCHAR(100),
    Market NVARCHAR(100),
    Location NVARCHAR(100),
    InvestmentStyle NVARCHAR(100)
)
