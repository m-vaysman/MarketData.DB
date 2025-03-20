CREATE TABLE [dbo].[TickerRefInfo]
(
	Ticker nvarchar(10) not null primary key,
	Company nvarchar(200) not null,
	Sector nvarchar(200),
	Industry nvarchar(200),
	MarketCap nvarchar(50),
	SingleCategory nvarchar(200),
	AssetType nvarchar(200),
	ETFType nvarchar(200),
	SectorTheme nvarchar(200)
)
