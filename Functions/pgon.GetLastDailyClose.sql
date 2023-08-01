CREATE FUNCTION [pgon].[GetLastDailyClose]
(
	@ticker varchar(max)
)
RETURNS FLOAT
AS
BEGIN
declare @price float
	select top 1 @price= [close] from pgon.DailySnapshotPrices where Ticker=@ticker 
	order by Date desc
	RETURN @price
END
