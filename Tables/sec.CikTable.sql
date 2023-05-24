CREATE TABLE [sec].[CikTable]
(

    cik_str INT not null, 
    CIK varchar(100) not null,
    ticker VARCHAR(255) NULL,
    title VARCHAR(255) NULL, 
    UpdateOn DATETIME DEFAULT GETDATE(),
    CONSTRAINT [AK_CikTable_Column] UNIQUE (cik_str,ticker)

)

GO

CREATE INDEX [IX_CikTable_Ticker] ON [sec].[CikTable] (ticker) 
go
CREATE INDEX [IX_CikTable_Cik_Str] ON [sec].[CikTable] (cik_str) 

GO

CREATE INDEX [IX_CikTable_CIK] ON [sec].[CikTable] (CIK)
