CREATE TABLE dbo.TickerReference (
    TickerReferenceId int identity(1,1) not null primary key,
    RunDate Date,
    Ticker nvarchar(10) not null,
    TickerRoot nvarchar(10) null,
    Name nvarchar(max),
    Description nvarchar(max),
    ListDate date,
    Locale nvarchar(10),
    Market nvarchar(10),
    Cik nvarchar(20),
    ShareClassFigi nvarchar(20),
    CompositeFigi nvarchar(20),
    CurrencyName nvarchar(10),
    MarketCap bigint,
    SicCode nvarchar(10),
    SicDescription nvarchar(max),
    PrimaryExchange nvarchar(10),
    ShareClassSharesOutstanding bigint,
    [Type] nvarchar(10),
    WeightedSharesOutstanding bigint,
    RoundLot int,
    TimeStamp datetime default current_timestamp not null, 
    CONSTRAINT [AK_TickerReference_RunDate_Ticker] UNIQUE ([RunDate],[Ticker])
);
GO

CREATE INDEX [IX_TickerReference_RunDate] ON [dbo].[TickerReference] ([RunDate])
