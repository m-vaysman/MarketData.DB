CREATE FUNCTION dbo.GetMinutePrice
(
    @priceType  VARCHAR(20),       -- expected values like 'Open','Close','High','Low','Close','Volume','Transactions'
    @ticker     VARCHAR(20),
    @offsetMinute INT,
    @timeToOffset DATETIME
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @targetTime DATETIME = DATEADD(MINUTE, @offsetMinute, @timeToOffset);
    DECLARE @result FLOAT;

    /* 
       Filter by Ticker + Date + DateTime to help the optimizer.
       Assumes one row per ticker per minute. If multiple, picks the first by DateTime.
       Returns NULL if nothing matches.
    */
    SELECT TOP (1)
        @result =
            CASE UPPER(CONVERT(NVARCHAR(32), @priceType))
                WHEN 'OPEN'         THEN CONVERT(FLOAT, mp.[Open])
                WHEN 'CLOSE'        THEN CONVERT(FLOAT, mp.[Close])
                WHEN 'HIGH'         THEN CONVERT(FLOAT, mp.[High])
                WHEN 'LOW'          THEN CONVERT(FLOAT, mp.[Low])
                WHEN 'VOLUME'       THEN CONVERT(FLOAT, mp.[Volume])
                WHEN 'TRANSACTIONS' THEN CONVERT(FLOAT, mp.[Transactions])
                ELSE NULL
            END
    FROM pgon.MinutePrice AS mp
    WHERE mp.Ticker = @ticker
      AND mp.[Date] = CAST(@targetTime AS DATE)
      AND mp.[DateTime] = @targetTime
    ORDER BY mp.[DateTime];  -- deterministic in case of duplicates

    RETURN @result;
END;
GO
