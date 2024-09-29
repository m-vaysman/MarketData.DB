CREATE FUNCTION [dbo].[GetCochransSampleSize]
(
    @PopulationSize INT,      -- Total population size
    @ConfidenceLevel FLOAT,   -- Confidence level (e.g., 1.96 for 95%)
    @MarginOfError FLOAT,     -- Margin of error (e.g., 0.05 for 5%)
    @StandardDeviation FLOAT   -- Estimated standard deviation
)
RETURNS INT
AS
BEGIN
    DECLARE @SampleSize INT;

    IF @PopulationSize <= 0 OR @MarginOfError <= 0 OR @StandardDeviation <= 0
    BEGIN
        RETURN 0; -- Invalid input
    END

    -- Sample size calculation formula
    DECLARE @Z FLOAT = @ConfidenceLevel;  -- Z value for the desired confidence level
    DECLARE @n FLOAT;

    SET @n = (POWER(@Z, 2) * @StandardDeviation * (1 - @StandardDeviation)) / POWER(@MarginOfError, 2);

    -- Finite population correction
    SET @SampleSize = ROUND(@n / (1 + ((@n - 1) / @PopulationSize)), 0);

    RETURN @SampleSize;
END;