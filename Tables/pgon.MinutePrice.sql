CREATE TABLE [pgon].[MinutePrice]
(
    [Id] bigint not null identity(1,1),
    [Ticker] NVARCHAR(10) NOT NULL, 
    [Date] DATE NOT NULL, 
    [DateTime] DateTime NOT NULL,
    [Volume] FLOAT NOT NULL, 
    [Open] FLOAT NOT NULL, 
    [Close] FLOAT NOT NULL, 
    [High] FLOAT NOT NULL, 
    [Low] FLOAT NOT NULL, 
    [Window_Start] BIGINT NOT NULL, 
    [Transactions] int not null,
    [CreatedOn] DATETIME not null default(getdate()), 

    CONSTRAINT [PK_MinutePrice] PRIMARY KEY CLUSTERED ([Date], [Ticker], [DateTime])

)on PS_MinutePrice(Ticker)

