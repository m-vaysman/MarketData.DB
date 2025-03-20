CREATE TABLE [dbo].[Dividend]
(
	Ticker nvarchar(10) not null,
	Dividend float null,
	DividendYield float null,
	PayoutRatio float null,
	CreatedOn DateTime  default(GETDATE()) not null
)
