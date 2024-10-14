CREATE TABLE [pgon].[RealTimeTrades]
(
  [Id] bigint not null identity(1,1),
	Ticker NVARCHAR(10),          -- Corresponds to "sym"
    Exchange INT,                 -- Corresponds to "x"
    Price Float,         -- Corresponds to "p"
    Conditions nvarchar(50),
    Size INT,                     -- Corresponds to "s"
    Timestamp BIGINT,             -- Corresponds to "t"
    Quantity INT,                 -- Corresponds to "q"
    Zone INT,
    CreatedOn DateTime default(GetDate()),-- Corresponds to "z"

) 
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CStoreIX_RealTimeTrades] ON [pgon].[RealTimeTrades]  with (MAXDOP =0, DATA_COMPRESSION=COLUMNSTORE)
on PS_RealTimeTrade(Exchange)
GO
CREATE NONCLUSTERED INDEX IDX_CreatedDate ON [pgon].[RealTimeTrades] (CreatedOn DESC)
GO
CREATE NONCLUSTERED INDEX IDX_Ticker ON [pgon].[RealTimeTrades] (Ticker) 



