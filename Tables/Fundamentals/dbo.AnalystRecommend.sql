CREATE TABLE [dbo].[AnalystRecommend]
(
	Ticker nvarchar(10) not null primary key,
	Value float null ,
	CreatedOn DateTime  default(GETDATE()) not null
)
