CREATE PROCEDURE [pgon].[GetStockPrice]
	@ticker varchar(max),
	@date DateTime
AS
	select Ticker, Price, [TimeStamp] from pgon.DailyTimeSeriesPrices where Ticker=@ticker and [TimeStamp]>@date and [TimeStamp]< DATEADD(DAY,1,@date)