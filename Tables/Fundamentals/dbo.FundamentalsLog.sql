CREATE TABLE [dbo].[FundamentalsLog]
(
    FundamentalsLogId int not null identity(1,1),
	FundamentalDataType nvarchar(50) not null,
	Ticker nvarchar(10) not null,
	Value float null,
	DateAsOf DateTime not null,
	CreatedOn DateTime  default(GETDATE()) not null
)
