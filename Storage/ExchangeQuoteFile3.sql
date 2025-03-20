/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [ExchangesQuoteFile3],
		FILENAME = 'D:\Db\ExchangeQuoteFile3.ndf',
		SIZE= 20000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) TO FILEGROUP ExchangeQuoteFileGroup3;
	
