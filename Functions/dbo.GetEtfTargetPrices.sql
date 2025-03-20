CREATE FUNCTION [dbo].[GetEtfTargetPrices]
(
	@currentDate DATE ,
    @ticker varchar(10) 
)
RETURNS @returntable TABLE
(
	
    FundTicker nvarchar(10),
    HoldingTicker nvarchar(50),
    SharesParValue bigint,
    MarketValue float,
    Weight float,
    Name nvarchar(255),
    Sector nvarchar(50),
    Date date,
    Ticker nvarchar(10),
    Products nvarchar(255),
    Category nvarchar(50),
    SubCategory nvarchar(50),
    TickerFromSnapShot varchar(50),
    DateFromSnapshot date,
    Volume float,
    VolumeWeighted float,
    [Open] float,
    [Close] float,
    High float,
    Low float,
    [Return] float,
    Drawdown float,
    Rise float,
    TargetPrice float

)
AS
BEGIN
DECLARE @marketDate Date;
SET @marketDate=@currentDate
	

INSERT @returntable
select 
      ieh.FundTicker
      ,ieh.HoldingTicker
      ,ieh.SharesParValue
      ,ieh.MarketValue
      ,ieh.Weight
      ,ieh.Name
      ,ieh.Sector
      ,ieh.Date
      ,ie.Ticker
      ,ie.Products
      ,ie.Category
      ,ie.SubCategory
      ,b.Ticker AS TickerFromSnapShot
      ,b.Date AS DateFromSnapshot
      ,b.Volume
      ,b.VolumeWeighted
      ,b.[Open]
      ,b.[Close]
      ,b.High
      ,b.Low
      ,b.[Return]
      ,b.Drawdown
      ,b.Rise
      ,tp.Value TargetPrice FROM InvescoEtfHoldings  ieh
 JOIN InvescoEtfs ie on ie.Ticker=ieh.FundTicker
 LEFT JOIN (SELECT * FROM pgon.DailySnapshotPricesMemOpt dsp WHERE dsp.Date=dbo.GetLastMarketDate(@marketDate)) b on b.Ticker=REPLACE(ieh.HoldingTicker,'/','.')
 LEFT JOIN TargetPrice tp on tp.Ticker=REPLACE(ieh.HoldingTicker,'/','.')
 where ieh.FundTicker=@ticker and b.Ticker is not null AND ieh.HoldingTicker<>'' AND ieh.HoldingTicker<>'-CASH-'
	RETURN 
END
