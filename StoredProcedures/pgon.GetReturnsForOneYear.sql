CREATE PROCEDURE [pgon].[GetReturnsForOneYear]
	@ticker nvarchar(10)
	
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,  -- Must be specified for natively compiled triggers
    LANGUAGE = N'English'
)
   DECLARE @Date DATE
   set @Date=DATEADD(day,-252,GETDATE());
  SELECT dsp.[Date], dsp.[Return] from pgon.DailySnapShotPricesMemOpt as dsp where dsp.Date>=@Date and dsp.Ticker=@ticker
  end
