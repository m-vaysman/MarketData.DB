CREATE TRIGGER [TargetPriceTrigger]
	ON [dbo].[TargetPrice]
	AFTER DELETE
	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.FundamentalsLog(FundamentalDataType, Ticker, [Value], DateAsOf )
		select 'TargetPrice', Ticker, [Value], CreatedOn from DELETED;
	END