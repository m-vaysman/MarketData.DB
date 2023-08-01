CREATE PROCEDURE [pgon].[GetLatestSnapshot]
	@startDateTime as DateTime,
	@endDateTime as DateTime
AS
DECLARE @date as Date=CONVERT(DATE,@startDateTime)
select * from (
	select b.Ticker,b.LastTime,c.Price, d.[Open], Log(c.Price/d.[Open]) as [Return] from(
select a.Ticker,Max(a.Ts) LastTime from (
select  Ticker, [TimeStamp] as Ts, Price from pgon.DailyTimeSeriesPrices where TimeStamp>@startDateTime and TimeStamp<@endDateTime  and Price> 7) as a
group by a.Ticker
) as b
inner join pgon.DailyTimeSeriesPrices as c on c.Ticker=b.Ticker and c.TimeStamp=b.LastTime
inner join pgon.DailySnapshotPrices as d on d.Ticker = c.Ticker and d.Date=@date) e
order by e.[Return] desc


