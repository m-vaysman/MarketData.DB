CREATE TRIGGER [EPSTrigger]
	ON [dbo].[EPS]
	AFTER DELETE
	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.FundamentalsLog(FundamentalDataType, Ticker, [Value], DateAsOf )
		select 'EPS', Ticker, [Value], CreatedOn from DELETED;
	END