CREATE FUNCTION [dbo].[GetTickerWinningStreak]
(
	@ticker varchar(10)
)
RETURNS @returntable TABLE
(
	Ticker varchar(10),
    Start_Date DATE,
    End_Date DATE,
    Streak_Length int
	
)
AS
BEGIN
WITH cte AS (
  SELECT 
    Ticker,
    Date,
    [Return],
    -- Create a grouping key that increments every time a non-positive return is encountered
    SUM(CASE WHEN [Return] <= 0 THEN 1 ELSE 0 END) OVER (PARTITION BY Ticker ORDER BY Date ROWS UNBOUNDED PRECEDING) AS grp
  FROM pgon.DailySnapShotPricesMemOpt where ticker=@ticker
),
streaks AS (
  SELECT 
    Ticker,
    MIN(Date) AS start_date,
    MAX(Date) AS end_date,
    COUNT(*) AS streak_length
  FROM cte
  WHERE [Return] > 0
  GROUP BY Ticker, grp
),
ranked AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY Ticker ORDER BY streak_length DESC) AS rn
  FROM streaks
)
insert into @returntable (Ticker,Start_Date,End_Date,Streak_Length)
SELECT 
  Ticker,
  start_date,
  end_date,
  streak_length
FROM ranked
WHERE rn = 1
ORDER BY streak_length DESC;
RETURN
END
