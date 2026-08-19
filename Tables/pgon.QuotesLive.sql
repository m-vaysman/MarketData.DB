CREATE TABLE pgon.QuotesLive
(
    captured_at     DATETIME2(3)    NOT NULL DEFAULT SYSUTCDATETIME(),
    ticker          NVARCHAR(10)    NOT NULL,
    bid             DECIMAL(18,6)   NOT NULL,
    ask             DECIMAL(18,6)   NOT NULL,
    midpoint        DECIMAL(18,6)   NOT NULL,
    spread_abs      DECIMAL(18,6)   NOT NULL,
    spread_bps      DECIMAL(10,2)   NOT NULL,
    bid_size        INT             NOT NULL,
    ask_size        INT             NOT NULL,
    total_depth     INT             NOT NULL
);