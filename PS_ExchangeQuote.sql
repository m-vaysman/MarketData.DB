CREATE PARTITION SCHEME [PS_ExchangeQuote]
	AS PARTITION [PF_ExchangeQuote]
	TO ([ExchangeQuoteFileGroup1], [ExchangeQuoteFileGroup2], [ExchangeQuoteFileGroup3])
