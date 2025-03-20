CREATE TABLE [ptf].[SecurityCorrelation]
(
	[Ticker_A] nvarchar(10) NOT NULL,
	[Ticker_B] nvarchar(10) NOT NULL,
	[Date] date NOT NULL,
	[Correlation] decimal(18,8) NOT NULL,
	[Offset] INT NOT NULL
--CONSTRAINT [UC_TickerABDate] PRIMARY KEY (Ticker_A, Ticker_B, [Date], [Offset]) with (data_compression=page)
)
on  [SecurityCorrelations] WITH (DATA_COMPRESSION = page);
go






CREATE NONclustered COLUMNSTORE INDEX [CStoreIX_SecurityCorrelation] ON [ptf].[SecurityCorrelation](Ticker_A, Ticker_B, [Date], [Offset])

go 

create nonclustered index [IX_tickera_tickerb_date] on ptf.securitycorrelation (ticker_a,ticker_b,[date]) include (correlation, offset) with (data_compression=page)

go 

create nonclustered index [ix_tickera_tickerb_date_offset] on ptf.securitycorrelation (ticker_a,ticker_b,[date],offset) include (correlation) with (data_compression=page)

go 
create nonclustered index [ix_tickera_offset] on ptf.securitycorrelation (ticker_a,offset) include (ticker_b,[date],correlation) with (data_compression=page)