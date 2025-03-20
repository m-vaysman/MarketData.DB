CREATE TABLE [dbo].[RsiMonthly]
(
	Ticker nvarchar(10) not null,
	Date DATE not null,
	DataPoint float not null,
	IndicatorMeasure int not null default(14),
	constraint PK_RsiMonthly PRIMARY KEY (Ticker, [Date])
)
