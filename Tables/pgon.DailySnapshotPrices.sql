CREATE TABLE [pgon].[DailySnapshotPrices]
(
	[DailySnapshotPricesId] INT NOT NULL PRIMARY KEY identity(1,1), 
    [Ticker] VARCHAR(50)NOT NULL, 
    [Date] DATE NOT NULL, 
    [Volume] FLOAT NULL, 
    [VolumeWeighted] FLOAT NULL, 
    [Open] FLOAT NULL, 
    [Close] FLOAT NULL, 
    [High] FLOAT NULL, 
    [Low] FLOAT NULL, 
    [Time] BIGINT NULL, 
    [Transactions] INT NULL, 
    [TransactionsDollars] FLOAT NULL, 
    [OpenCloseChange] FLOAT NULL, 
    [OpenCloseChangeRank] INT NULL, 
    [TransactionsRank] INT NULL, 
    [TransactionsDollarsRank] INT NULL, 
    [UpdatedOn] DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
)

GO

CREATE INDEX [IX_DailySnapshotPrices_Column] ON [pgon].[DailySnapshotPrices] ([Ticker],[Date])

GO

CREATE INDEX [IX_DailySnapshotPrices_Date] ON [pgon].[DailySnapshotPrices] ([Date])

GO

CREATE INDEX [IX_DailySnapshotPrices_Ticker_OpenCloseChange] ON [pgon].[DailySnapshotPrices] ([Ticker]) INCLUDE ([Date], [OpenCloseChange])

GO

CREATE NONCLUSTERED INDEX [IX_DailySnapshotPrices_Ticker_DateClose]
ON [pgon].[DailySnapshotPrices] ([Ticker])
INCLUDE ([Date],[Close])

GO


CREATE NONCLUSTERED INDEX [IX_DailySnapshotPrices_Ticker_DateCloseLowMax]
ON [pgon].[DailySnapshotPrices] ([Date])
INCLUDE ([Ticker],[Close],[Low],[High])
go
CREATE NONCLUSTERED INDEX [IX_DailySnapshotPrices_TickerDate_DateCloseLowMax]
ON [pgon].[DailySnapshotPrices] ([Ticker])
INCLUDE ([Date] ,[Close],[Low],[High])
