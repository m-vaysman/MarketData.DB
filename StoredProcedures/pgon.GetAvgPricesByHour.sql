CREATE PROCEDURE [pgon].[GetAvgPricesByHour]
	@startDate DATE,
	@endDate DATE
AS
	
select b.Ticker,b.hour as [Hour],AVG(Price) as Average from(
select *, DATEPART(HOUR,TimeStamp) as hour from pgon.DailyTimeSeriesPrices where  timestamp>@startDate and TimeStamp< @endDate)
as b 
group by b.ticker, b.hour
order by b.ticker, b.hour

