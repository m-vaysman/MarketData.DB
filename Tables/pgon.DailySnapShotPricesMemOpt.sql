/*
The database must have a MEMORY_OPTIMIZED_DATA filegroup
before the memory optimized object can be created.

The bucket count should be set to about two times the 
maximum expected number of distinct values in the 
index key, rounded up to the nearest power of two.
*/

CREATE TABLE [pgon].[DailySnapShotPricesMemOpt]
(

    [Ticker]                  VARCHAR (50) NOT NULL,
    [Date]                    DATE         NOT NULL,
    [Volume]                  FLOAT (53)   NULL,
    [VolumeWeighted]          FLOAT (53)   NULL,
    [Open]                    FLOAT (53)   NULL,
    [Close]                   FLOAT (53)   NULL,
    [High]                    FLOAT (53)   NULL,
    [Low]                     FLOAT (53)   NULL, 
    PRIMARY KEY NONCLUSTERED HASH (Ticker,[Date]) WITH (BUCKET_COUNT = 40000000),
    INDEX [IX_DailySnapShotPricesMemOpt_Date] NONCLUSTERED HASH ([Date]) WITH (BUCKET_COUNT = 7000),
    INDEX [IX_DailySnapShotPricesMemOpt_Ticker] NONCLUSTERED HASH ([Ticker]) WITH (BUCKET_COUNT = 40000),
 
   
) WITH (MEMORY_OPTIMIZED = ON)
go


GO

CREATE NONCLUSTERED  INDEX [IX_DailySnapshotPricesMemOpt_Ticker_OpenCloseHighLow] ON [pgon].[DailySnapshotPrices] ([Ticker]) INCLUDE ([Date],[Open],[High],[Close],[Low],[Volume])

GO
CREATE NONCLUSTERED  INDEX [IX_DailySnapshotPricesMemOpt_Date_OpenCloseHighLow] ON [pgon].[DailySnapshotPrices] ([Date]) INCLUDE (Ticker,[Open],[High],[Close],[Low],[Volume])
GO
CREATE NONCLUSTERED  INDEX [IX_DailySnapshotPricesMemOpt_TickerDate_OpenCloseHighLow] ON [pgon].[DailySnapshotPrices] (Ticker,[Date]) INCLUDE ([Open],[High],[Close],[Low],[Volume])
