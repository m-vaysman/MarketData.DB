CREATE TABLE [dbo].[EtfReference]
(
 Ticker nvarchar(10) NOT NULL primary key,
 FundName nvarchar(150) NOT NULL,
 ISIN nvarchar(12)  NULL,
 CUSIP nvarchar(9)  NULL,
InceptionDate Date null,
AssetClass nvarchar(50) null,
PrimaryIndex nvarchar(150) null,
PrimaryIndexTicker nvarchar(15) null
)
