/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [ExchangeQuoteFile2],
		FILENAME = 'G:\Db\ExchangeQuoteFile2.ndf',
		SIZE= 20000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) To FILEGROUP ExchangeQuoteFileGroup2
	
