CREATE PROCEDURE pgon.MoveExchangesQuotes
AS
BEGIN
    -- Set XACT_ABORT ON to ensure that the transaction is rolled back in case of an error
    SET XACT_ABORT ON;
    
    -- Begin a transaction
    BEGIN TRANSACTION;

    -- Insert data from staging to pgon.ExchangeQuotes, with necessary transformations
    INSERT INTO [pgon].[ExchangeQuotes] 
    (
        ticker,
        ask_exchange,
        ask_price,
        ask_size,
        bid_exchange,
        bid_price,
        bid_size,
        conditions,
        indicators,
        date,
        participant_timestamp,
        sequence_number,
        sip_timestamp,
        tape,
        CreateDate
    )
    SELECT
        CAST(ticker AS NVARCHAR(10)),    -- Convert ticker from varchar(50) to nvarchar(10)
        ask_exchange,
        ask_price,
        ask_size,
        bid_exchange,
        bid_price,
        bid_size,
        CAST(conditions AS NVARCHAR(100)),  -- Convert conditions to nvarchar(100)
        CAST(indicators AS NVARCHAR(100)),  -- Convert indicators to nvarchar(100)
         dbo.MillisecondsToDate(participant_timestamp/1000000),            -- Set the current date for the 'date' column
        participant_timestamp,
        sequence_number,
        sip_timestamp,
        tape,
        GETDATE()                           -- Insert the current timestamp into CreateDate
    FROM [staging].[ExchangesQuotes]
    WHERE ticker IS NOT NULL  -- Ensure that NULL values in 'ticker' don't violate the NOT NULL constraint
      AND ask_exchange IS NOT NULL
      AND ask_price IS NOT NULL
      AND ask_size IS NOT NULL
      AND bid_exchange IS NOT NULL
      AND bid_price IS NOT NULL
      AND bid_size IS NOT NULL
      AND participant_timestamp IS NOT NULL
      AND sequence_number IS NOT NULL
      AND sip_timestamp IS NOT NULL
      AND tape IS NOT NULL;

    -- Check for errors and commit or rollback transaction
    IF @@ERROR = 0
    BEGIN
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50000, 'Error occurred while moving data from staging to pgon', 1;
    END
END;
