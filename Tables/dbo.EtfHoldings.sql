CREATE TABLE [dbo].[EtfHoldings]
(
	[EtfHoldingsId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[EtfHoldingsMapId] INT NOT NULL,
	[Ticker] NVARCHAR(10)  NULL,
	[Name] NVARCHAR(100)  NULL,
	[Identifier] NVARCHAR(12)  NULL,
    [Weight] DECIMAL(28, 4)  NULL,
	[Sector] NVARCHAR(100)  NULL,
	[SharesHeld] DECIMAL(28, 4)  NULL,
	[CouponRate] DECIMAL(28, 4)  NULL,
    [MaturityDate] DATE  NULL,
	[EffectiveDate] DATE  NULL,
	[NextCallDate] DATE  NULL,
	[Rating] nvarchar(50)  NULL,
	[MarketValue] DECIMAL(28, 10)  NULL,
	[PercentageOfFund] DECIMAL(28, 4)  NULL,
	[ShortName] NVARCHAR(100)  NULL,
	[Sedol] NVARCHAR(12)  NULL,
	[FIGI] nvarchar(25)  NULL



  CONSTRAINT [FK_EtfHoldings_ToTable] FOREIGN KEY ([EtfHoldingsMapId]) REFERENCES [EtfHoldingsMap]([EtfHoldingsMapId])
);