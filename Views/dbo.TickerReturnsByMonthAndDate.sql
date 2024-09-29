CREATE VIEW [dbo].[TickerReturnsByMonthAndDate]
	AS 
	
	select avg(c.DailyReturn) AvgReturn,c.Day,c.Month,c.MonthName,c.WeekdayName,c.Quarter from (
	SELECT a.DailyReturn, b.Month,b.Day,b.MonthName, b.Quarter,b.WeekdayName FROM pgon.TickerDailyReturns a
	join DateTable b on b.DateID=a.Date
	WHERE a.Ticker='SPY'
	) c
	group by c.Month,c.Day,c.MonthName,c.Quarter,c.WeekdayName
	
