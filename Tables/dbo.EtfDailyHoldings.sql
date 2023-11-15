CREATE TABLE [dbo].[EtfDailyHoldings] (
    [EtfDailyHoldingsId]   INT             IDENTITY (1, 1) NOT NULL,
    [FundHoldingsAsOfDate] DATE            NOT NULL,
    [FundTicker]           NVARCHAR (10)   NOT NULL,
    [Name]                 NVARCHAR (100)  NULL,
    [Sector]               NVARCHAR (100)  NULL,
    [AssetClass]           NVARCHAR (100)  NULL,
    [MarketValue]          DECIMAL (28, 4) NULL,
    [Weight]               DECIMAL (28, 4) NULL,
    [NotionalValue]        DECIMAL (28, 4) NULL,
    [ParValue]             DECIMAL (28, 4) NULL,
    [CUSIP]                NVARCHAR (100)  NULL,
    [ISIN]                 NVARCHAR (100)  NULL,
    [SEDOL]                NVARCHAR (100)  NULL,
    [Location]             NVARCHAR (100)  NULL,
    [Exchange]             NVARCHAR (100)  NULL,
    [Currency]             NVARCHAR (100)  NULL,
    [Duration]             DECIMAL (28, 4) NULL,
    [YTM]                  DECIMAL (28, 4) NULL,
    [FXRate]               DECIMAL (28, 4) NULL,
    [Maturity]             DATE            NULL,
    [Coupon]               DECIMAL (28, 4) NULL,
    [ModDuration]          DECIMAL (28, 4) NULL,
    [YieldtoCall]          DECIMAL (28, 4) NULL,
    [YieldtoWorst]         DECIMAL (28, 4) NULL,
    [RealDuration]         DECIMAL (28, 4) NULL,
    [RealYTM]              DECIMAL (28, 4) NULL,
    [MarketCurrency]       NVARCHAR (100)  NULL,
    [AccrualDate]          DATE            NULL,
    [EffectiveDate]        DATE            NULL,
    [Ticker]               NVARCHAR (100)  NULL,
    [Shares]               DECIMAL (28, 4) NULL,
    [Price]                DECIMAL (28, 4) NULL,
    [Type]                 NVARCHAR (100)  NULL,
    [TimeStamp]            DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([EtfDailyHoldingsId] ASC),
    CONSTRAINT [FK_EtfDailyHoldings_EtfSecurityReference] FOREIGN KEY ([FundTicker]) REFERENCES [dbo].[EtfSecurityReference] ([FundTicker])
);



go
CREATE COLUMNSTORE INDEX CSX_EtfDailyHoldings_FundTicker
ON dbo.EtfDailyHoldings (FundTicker)
GO