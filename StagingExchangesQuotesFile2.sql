/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [StagingExchangesQuotesFile2],
		FILENAME = 'G:\Db\StagingExchangesQuotesFile2.ndf',
		SIZE= 10000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) TO FILEGROUP ExchangesQuotesFileGroup2;
	
	
