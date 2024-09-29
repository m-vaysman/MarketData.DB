CREATE FUNCTION [dbo].[GetPrice]
(
    @ticker nvarchar(50),
    @date date,
    @priceType nvarchar(10) = 'close'
)
RETURNS float
AS
BEGIN
    DECLARE @Price float;

    -- Correct the CASE expression and remove the alias inside CASE
    SELECT TOP 1
        @Price = CASE 
                    WHEN @priceType = 'close' THEN a.[Close] 
                    WHEN @priceType = 'open' THEN a.[Open]
                    WHEN @priceType = 'high' THEN a.[High]
                    ELSE a.[Low]
                 END
    FROM pgon.DailySnapshotPrices AS a 
    WHERE a.Ticker = @ticker 
    AND a.Date = @date;

    RETURN @Price;
END;
GO
