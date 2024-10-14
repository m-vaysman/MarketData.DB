CREATE TABLE [dbo].[TickerIndex]
(
	Ticker nvarchar(10) NOT NULL PRIMARY KEY,
	[Index] nvarchar(50) NULL,
	CreatedOn DateTime default(GETDATE()) not null
)
