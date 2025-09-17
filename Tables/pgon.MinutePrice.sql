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

    CONSTRAINT [PK_MinutePrice] PRIMARY KEY (Id,[Ticker],[Window_Start])
    
)on PS_MinutePrice(Ticker)


go

create nonclustered index IX_MinutePrice_Ticker ON pgon.MinutePrice  ([Ticker]) include ([Date],Volume,[Open],[Close],[High],[Low],[Window_Start],[Transactions])
go
CREATE NONCLUSTERED INDEX IX_MarketData_MinutePrice_Ticker_Date 
ON pgon.MinutePrice ([Ticker], [Date])
INCLUDE ([Open], [Close],[High],[Low],[Transactions],[DateTime]);
go
CREATE NONCLUSTERED INDEX IX_MarketData_Date 
ON pgon.MinutePrice ([Date])
INCLUDE ([Ticker],[Open], [Close],[High],[Low],[Transactions],[DateTime]);
GO
CREATE NONCLUSTERED INDEX IX_MarketData_DateTime 
ON pgon.MinutePrice ([Ticker],[DateTime])
INCLUDE ([Date],[Open], [Close],[High],[Low],[Transactions]);
