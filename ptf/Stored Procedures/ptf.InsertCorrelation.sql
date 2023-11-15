CREATE PROCEDURE [ptf].[InsertCorrelation]
	
  @Ticker_A  varchar(10)
 ,@Ticker_B  varchar(10)
 ,@Date  datetime
  ,@Correlation  decimal(18, 8)
 ,@Offset  int
AS
	INSERT INTO ptf.SecurityCorrelation
(
  Ticker_A
 ,Ticker_B
 ,Date
 ,Correlation
 ,Offset

)
VALUES
(
  @Ticker_A
 ,@Ticker_B
 ,@Date
 ,@Correlation
 ,@Offset
 
);
RETURN 0