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
        date,
        ticker,
        sip_timestamp,
        participant_timestamp,
        sequence_number,
        ask_exchange,
        ask_price,
        ask_size,
        bid_exchange,
        bid_price,
        bid_size,
        conditions,
        indicators,
        tape
    )
    SELECT
        dbo.MillisecondsToDate(participant_timestamp/1000000),  -- derive date from participant_timestamp
        CAST(ticker AS NVARCHAR(10)),
        sip_timestamp,
        participant_timestamp,
        CAST(sequence_number AS BIGINT),                        -- INT may overflow at this volume
        ask_exchange,
        CAST(ask_price AS DECIMAL(18,6)),                       -- not float
        ask_size,
        bid_exchange,
        CAST(bid_price AS DECIMAL(18,6)),                       -- not float
        bid_size,
        CAST(conditions AS NVARCHAR(100)),
        CAST(indicators AS NVARCHAR(100)),
        tape
    FROM [staging].[ExchangesQuotes]
    WHERE ticker IS NOT NULL
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
