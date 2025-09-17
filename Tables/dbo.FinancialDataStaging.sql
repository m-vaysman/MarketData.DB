CREATE TABLE [dbo].[FinancialDataStaging]
(
	[FinancialDataId] INT NOT NULL PRIMARY KEY identity(1,1),
	Ticker varchar(20) not null,
	DataPoint varchar(300) not null,
	FiscalPeriod varchar(20) not null,
	FiscalYear int not null,
	TimeFrame varchar(300),
	[Value] float not null,
	CreatedOn DateTime DEFAULT GetDate() not null
)
