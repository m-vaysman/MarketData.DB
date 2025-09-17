CREATE TABLE [dbo].[FinancialData]
(
	[FinancialDataId] INT NOT NULL  identity(1,1),
	Ticker varchar(20) not null,
	DataPoint varchar(300) not null,
	FiscalPeriod varchar(20) not null,
	FiscalYear int not null,
	TimeFrame varchar(300),
	[Value] float not null,
	CreatedOn DateTime DEFAULT GetDate() not null 
    constraint unique_columns_financial_data_ix unique(Ticker,DataPoint,FiscalPeriod,FiscalYear, TimeFrame)
)