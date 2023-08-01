CREATE TABLE [pgon].[DailyTimeSeriesPrices]
(
	[Id] BIGINT NOT NULL PRIMARY KEY identity(1,1),
	[Ticker] varchar(50) not null,
	[Price] float not null,
	[TimeStamp] DateTime not null
)

GO


CREATE INDEX [IX_DailyTimeSeriesPrices_Column] ON [pgon].[DailyTimeSeriesPrices] ([TimeStamp],[Ticker])INCLUDE(Price)

GO

CREATE INDEX [IX_DailyTimeSeriesPrices_Column_1] ON [pgon].[DailyTimeSeriesPrices] ([TimeStamp]) INCLUDE(Ticker,Price)
