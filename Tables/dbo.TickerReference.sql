CREATE TABLE [dbo].[TickerReference] (
    [TickerReferenceId]           INT            IDENTITY (1, 1) NOT NULL,
    [RunDate]                     DATE           NULL,
    [Ticker]                      NVARCHAR (10)  NOT NULL,
    [TickerRoot]                  NVARCHAR (10)  NULL,
    [Name]                        NVARCHAR (MAX) NULL,
    [Description]                 NVARCHAR (MAX) NULL,
    [ListDate]                    DATE           NULL,
    [Locale]                      NVARCHAR (10)  NULL,
    [Market]                      NVARCHAR (10)  NULL,
    [Cik]                         NVARCHAR (20)  NULL,
    [ShareClassFigi]              NVARCHAR (20)  NULL,
    [CompositeFigi]               NVARCHAR (20)  NULL,
    [CurrencyName]                NVARCHAR (10)  NULL,
    [MarketCap]                   BIGINT         NULL,
    [SicCode]                     NVARCHAR (10)  NULL,
    [SicDescription]              NVARCHAR (MAX) NULL,
    [PrimaryExchange]             NVARCHAR (10)  NULL,
    [ShareClassSharesOutstanding] BIGINT         NULL,
    [Type]                        NVARCHAR (10)  NULL,
    [WeightedSharesOutstanding]   BIGINT         NULL,
    [RoundLot]                    INT            NULL,
    [TimeStamp]                   DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([TickerReferenceId] ASC),
    CONSTRAINT [AK_TickerReference_RunDate_Ticker] UNIQUE NONCLUSTERED ([RunDate] ASC, [Ticker] ASC)
);


GO

CREATE INDEX [IX_TickerReference_RunDate] ON [dbo].[TickerReference] ([RunDate])
