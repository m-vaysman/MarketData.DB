/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [ExchangesQuoteFile1],
		FILENAME = 'I:\Db\ExchangeQuoteFile1.ndf',
		SIZE= 20000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) TO FILEGROUP ExchangeQuoteFileGroup1;
	
