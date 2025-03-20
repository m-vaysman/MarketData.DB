CREATE TRIGGER [QuickRatioTrigger]
	ON [dbo].[QuickRatio]
	AFTER DELETE
	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.FundamentalsLog(FundamentalDataType, Ticker, [Value], DateAsOf )
		select 'QuickRatio', Ticker, [Value], CreatedOn from DELETED;
	END