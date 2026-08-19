CREATE TABLE [pgon].[ExchangeQuotes]
(
    date                    DATE            NOT NULL,   -- partition column first
    ticker                  NVARCHAR(10)    NOT NULL,
    sip_timestamp           BIGINT          NOT NULL,
    participant_timestamp   BIGINT          NOT NULL,
    sequence_number         BIGINT          NOT NULL,   -- INT may overflow at this volume
    ask_exchange            TINYINT         NOT NULL,
    ask_price               DECIMAL(18,6)   NOT NULL,   -- not float
    ask_size                INT             NOT NULL,
    bid_exchange            TINYINT         NOT NULL,
    bid_price               DECIMAL(18,6)   NOT NULL,   -- not float
    bid_size                INT             NOT NULL,
    conditions              NVARCHAR(100)   NULL,
    indicators              NVARCHAR(100)   NULL,
    tape                    TINYINT         NOT NULL
    -- dropped CreateDate: it's always ~load time, rarely queried,
    -- and costs 8 bytes * billions of rows. Add back if you need it.
)
ON ps_QuoteDate([date]);
GO

-- This IS your lookup index. No separate NCI needed.
CREATE CLUSTERED INDEX CIX_ExchangeQuotes
ON [pgon].[ExchangeQuotes] ([date], ticker, sip_timestamp)
WITH (DATA_COMPRESSION = PAGE)
ON ps_QuoteDate([date]);
GO
