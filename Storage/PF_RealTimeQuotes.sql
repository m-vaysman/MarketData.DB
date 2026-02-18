/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [RealTimeQuotes_Data],
		FILENAME = 'I:\Db\RealTimeQuotes_Data.ndf',
		SIZE= 50000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=10000MB
	) TO FILEGROUP FG_RealTimeQuotes;
