CREATE TABLE [ptf].[Portfolio]
(
	[Id] INT NOT NULL PRIMARY KEY identity( 1,1),
	Ptf nvarchar(20) not null,
	Ticker nvarchar(10) not null,
	TradeDate DATE not null,
	Weight int not null

	constraint ix_portfolio_unique unique (Ptf,Ticker,TradeDate)

)
