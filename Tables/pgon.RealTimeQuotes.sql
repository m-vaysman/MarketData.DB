CREATE TABLE [pgon].[RealTimeQuotes]
(
	[Date] DATE NOT NULL,
	[Ticker] VARCHAR(10) NOT NULL,
	[AskExchange] INT NOT NULL,
	[AskPrice] FLOAT NOT NULL,
	[AskSize] FLOAT NOT NULL,
	[BidExchange] INT NOT NULL,
	[BidPrice] FLOAT NOT NULL,
	[BidSize] FLOAT NOT NULL,
	[Conditions] VARCHAR(50) NULL,
	[Indicators] VARCHAR(50) NULL,
	[ParticipantTimestamp] BIGINT NOT NULL,
	[SequenceNumber] BIGINT NOT NULL,
	[SipTimestamp] BIGINT NOT NULL,
	[Tape] TINYINT NOT NULL,
	[TrfTimestamp] BIGINT NOT NULL,
	[Spread] AS ([AskPrice] - [BidPrice]),
	[MidPrice] AS (([AskPrice] + [BidPrice]) / 2.0)
) ON [PS_QuoteDate]([Date])
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_RealTimeQuotes] ON [pgon].[RealTimeQuotes] WITH (MAXDOP = 0, DATA_COMPRESSION = COLUMNSTORE)
ON [PS_QuoteDate]([Date])
