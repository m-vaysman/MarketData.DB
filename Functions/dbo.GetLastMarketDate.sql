CREATE FUNCTION [dbo].[GetLastMarketDate](@date DATE null)
RETURNS DATE
AS
BEGIN
    DECLARE @LastMarketDate DATE;

    SELECT TOP 1 @LastMarketDate = DateID
    FROM dateTable
    WHERE DateID < ISNULL(@date,CAST(GETDATE() AS DATE))
        AND DateID NOT IN (SELECT [Date] FROM marketholidays)
        AND DATENAME(WEEKDAY, DateID) NOT IN ('Saturday', 'Sunday')
    ORDER BY DateID DESC;

    RETURN @LastMarketDate;
END;

