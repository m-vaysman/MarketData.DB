/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [RealTimeTrade2],
		FILENAME = 'G:\Db\RealTimeTrade2.ndf',
		SIZE= 4000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) TO FILEGROUP FG_RealTimeTrade2;