CREATE TABLE [ptf].[SecurityCorrelation]
(
	[SecurityCorrelationId] bigINT NOT NULL PRIMARY KEY identity(1,1),
	[Ticker_A] varchar(10) NOT NULL,
	[Ticker_B] varchar(10) NOT NULL,
	[Date] date NOT NULL,
	[Correlation] decimal(18, 8) NOT NULL,
	[Offset] INT NOT NULL
)

GO

--CREATE COLUMNSTORE INDEX [CStoreIX_SecurityCorrelation] ON [ptf].[SecurityCorrelation] ([Ticker_A],[Ticker_B],[Date],[Offset],[Correlation])



CREATE INDEX [IX_SecurityCorrelation_TickerB_Date] ON [ptf].[SecurityCorrelation] ([Ticker_B],[Date]) include ([Ticker_A],[Correlation],[Offset])  WITH (DATA_COMPRESSION = PAGE);

GO

CREATE INDEX [IX_SecurityCorrelation_TickerA_Date] ON [ptf].[SecurityCorrelation] ([Ticker_A],[Date]) include ([Ticker_B],[Correlation],[Offset]) WITH (DATA_COMPRESSION = PAGE);

