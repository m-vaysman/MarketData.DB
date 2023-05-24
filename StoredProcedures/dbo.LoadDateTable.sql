CREATE PROCEDURE [dbo].[LoadDateTable]
	@StartDate DATE,
	@EndDate DATE
AS

-- Populate the date table
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO DateTable (DateID, [Year], [Month], [Day], [Weekday], [Quarter], [DayOfYear], [Week], [MonthName], [WeekdayName])
    VALUES (
        @CurrentDate,
        YEAR(@CurrentDate),
        MONTH(@CurrentDate),
        DAY(@CurrentDate),
        DATEPART(WEEKDAY, @CurrentDate),
        DATEPART(QUARTER, @CurrentDate),
        DATEPART(DAYOFYEAR, @CurrentDate),
        DATEPART(WEEK, @CurrentDate),
        DATENAME(MONTH, @CurrentDate),
        DATENAME(WEEKDAY, @CurrentDate)
    );
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;
RETURN 0
