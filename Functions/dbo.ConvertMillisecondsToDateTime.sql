CREATE FUNCTION dbo.MillisecondsToDateTime(@Milliseconds BIGINT)
RETURNS DATETIME2
AS
BEGIN
    -- Convert milliseconds to seconds and milliseconds, then add to the epoch start date (1970-01-01)
    RETURN DATEADD(MILLISECOND, @Milliseconds % 1000, DATEADD(SECOND, @Milliseconds / 1000, '1970-01-01'));
END;