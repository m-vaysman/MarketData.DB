/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [MinutePrice],
		FILENAME = 'F:\Db\MinutePrice.ndf',
		SIZE= 1000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) TO FILEGROUP FG_MinutePrice;
