CREATE PARTITION FUNCTION [PF_StagingExchangesQuotes]
	(
		tinyint
	)
	AS RANGE LEFT
	FOR VALUES (11)
