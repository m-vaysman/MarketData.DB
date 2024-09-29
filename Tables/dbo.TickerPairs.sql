CREATE TABLE [dbo].[TickerPairs]
(
	TickerPairsId INT NOT NULL PRIMARY KEY identity(1,1),
	TickerA nvarchar(10) not null,
	TickerB nvarchar(10) not null, 
    CONSTRAINT [AK_TickerPairs_Column] UNIQUE ([TickerA],[TickerB])

)

GO

CREATE INDEX [IX_TickerPairs_TickerA] ON [dbo].[TickerPairs] ([TickerA])
GO
CREATE INDEX [IX_TickerPairs_TickerB] ON [dbo].[TickerPairs] ([TickerB])
