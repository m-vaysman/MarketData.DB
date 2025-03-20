CREATE PARTITION SCHEME [PS__StagingExchangesQuotes]
	AS PARTITION [PF_StagingExchangesQuotes]
	TO ([ExchangesQuotesFileGroup1], [ExchangesQuotesFileGroup2])
