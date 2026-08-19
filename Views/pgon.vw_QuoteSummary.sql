CREATE VIEW pgon.vw_QuoteSummary
WITH SCHEMABINDING
AS
SELECT 
    [date],
    ticker,
    COUNT_BIG(*) AS quotes,
    SUM(ask_price - bid_price) AS total_spread,
    SUM(ask_price) AS total_ask,
    SUM(bid_price) AS total_bid,
    SUM(CAST(ask_size AS BIGINT)) AS total_ask_size,
    SUM(CAST(bid_size AS BIGINT)) AS total_bid_size
FROM pgon.ExchangeQuotes
GROUP BY [date], ticker;
GO

CREATE UNIQUE CLUSTERED INDEX CIX_QuoteSummary
ON pgon.vw_QuoteSummary ([date], ticker)
WITH (MAXDOP = 0);  -- 0 = use all cores