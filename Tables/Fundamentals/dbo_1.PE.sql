CREATE TRIGGER [PETrigger]
	ON [dbo].[PE]
	AFTER DELETE
	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.FundamentalsLog(FundamentalDataType, Ticker, [Value], DateAsOf )
		select 'PE', Ticker, [Value], CreatedOn from DELETED;
	END