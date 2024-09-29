CREATE TABLE [pgon].[ExchangeQuotes]
(
    
	ticker nvarchar(10) not null,
	ask_exchange tinyint not null,
	ask_price float not null,
	ask_size int not null,
	bid_exchange tinyint not null,
	bid_price float not null,
	bid_size int not null,
	conditions nvarchar(100),
	indicators nvarchar(100),
	date [date] not null,
	participant_timestamp bigint not null,
	sequence_number int not null,
	sip_timestamp bigint not null,
	tape tinyint not null,
	CreateDate DateTime default(getdate()) not null

)
ON PS_ExchangeQuote (ticker)

