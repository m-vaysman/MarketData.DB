CREATE TABLE [dbo].[DividendInfo]
(
	[Id] INT NOT NULL PRIMARY KEY identity(1,1),
	
	Ticker nvarchar(10) not null,
	RecordDate DATE null,
	PayDate DATE null,
	Frequency int null,
	ExDividendDate DATE null,
	DividendType nvarchar(10),
	DeclarationDate DATE null,
	CashAmount float null,
	Currency nvarchar(10) null,
	CreatedOn DATETIME default GETDATE() not null

)
