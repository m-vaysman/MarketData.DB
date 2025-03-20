CREATE TRIGGER [FundamentalsTrigger]
	ON [dbo].[ForwardPE]
	AFTER DELETE
	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.FundamentalsLog(FundamentalDataType, Ticker, [Value], DateAsOf )
		select 'ForwardPE', Ticker, [Value], CreatedOn from DELETED;
	END
