CREATE TABLE [pgon].[DailySnapshotPrices] (
    [DailySnapshotPricesId]   INT    PRIMARY KEY NONCLUSTERED   IDENTITY (1, 1) NOT NULL,
    [Ticker]                  VARCHAR (50) NOT NULL,
    [Date]                    DATE         NOT NULL,
    [Volume]                  FLOAT (53)   NULL,
    [VolumeWeighted]          FLOAT (53)   NULL,
    [Open]                    FLOAT (53)   NULL,
    [Close]                   FLOAT (53)   NULL,
    [High]                    FLOAT (53)   NULL,
    [Low]                     FLOAT (53)   NULL,
    [Time]                    BIGINT       NULL,
    [Transactions]            INT          NULL,
    [TransactionsDollars]     FLOAT (53)   NULL,
    [OpenCloseChange]         FLOAT (53)   NULL,
    [OpenCloseChangeRank]     INT          NULL,
    [TransactionsRank]        INT          NULL,
    [TransactionsDollarsRank] INT          NULL,
    [UpdatedOn]               DATETIME     DEFAULT (getdate()) NOT NULL
 
);
go
CREATE CLUSTERED COLUMNSTORE INDEX [CStoreIX_DailySnapshotPrices] ON [pgon].[DailySnapshotPrices]  with (MAXDOP =0, DATA_COMPRESSION=COLUMNSTORE)


GO

CREATE INDEX [IX_DailySnapshotPrices_Column] ON [pgon].[DailySnapshotPrices] ([Ticker],[Date])
INCLUDE ([High], [Close]) with (DATA_COMPRESSION = PAGE)
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
    ON [pgon].[DailySnapshotPrices]([Date] ASC)
    INCLUDE([Ticker],[Volume], [VolumeWeighted], [Close], [Low], [High]);


go
CREATE NONCLUSTERED INDEX [IX_DailySnapshotPrices_TickerDate_DateCloseLowMax]
ON [pgon].[DailySnapshotPrices] ([Ticker])
INCLUDE ([Date] ,[Close],[Low],[High])

GO


