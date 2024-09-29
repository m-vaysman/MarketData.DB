CREATE TABLE [staging].[ExchangesQuotes]
(
	ticker varchar(50),
	ask_exchange tinyint ,
	ask_price float,
	ask_size int,
	bid_exchange tinyint,
	bid_price float,
	bid_size int,
	conditions varchar(max),
	indicators varchar(max),
	participant_timestamp bigint,
	sequence_number int,
	sip_timestamp bigint,
	tape tinyint,
	trf_timestamp bigint

)
ON PS__StagingExchangesQuotes (bid_exchange)
