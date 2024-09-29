CREATE FUNCTION dbo.MillisecondsToDate(@Milliseconds BIGINT)
RETURNS DATE
AS
BEGIN
    -- Convert milliseconds to seconds, then add to the epoch start date (1970-01-01)
    RETURN CAST(DATEADD(SECOND, @Milliseconds / 1000, '1970-01-01') AS DATE);
END;