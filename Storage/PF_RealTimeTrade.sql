/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [RealTimeTrade],
		FILENAME = 'F:\Db\RealTimeTrade.ndf',
		SIZE= 4000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) TO FILEGROUP FG_RealTimeTrade;
