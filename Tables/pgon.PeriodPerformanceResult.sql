CREATE TYPE [pgon].[PeriodPerformanceResult] AS TABLE
(
    [Ticker]                   NVARCHAR(50)  NOT NULL,
    [PeriodType]               NVARCHAR(10)  NOT NULL,
    [PeriodEndDate]            DATE          NOT NULL,
    [PeriodEndClose]           FLOAT(53)     NULL,
    [PreviousPeriodEndClose]   FLOAT(53)     NULL,
    [Performance]              FLOAT(53)     NULL,

    INDEX [IX_PeriodPerformanceResult] NONCLUSTERED (Ticker, PeriodType)
)
WITH (MEMORY_OPTIMIZED = ON);
GO
