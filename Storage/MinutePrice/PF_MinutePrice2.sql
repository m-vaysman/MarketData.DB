/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/
ALTER DATABASE [$(DatabaseName)]
	ADD FILE
	(
		NAME = [MinutePrice2],
		FILENAME = 'G:\Db\MinutePrice2.ndf',
		SIZE= 1000MB,
		MAXSIZE=UNLIMITED,
		FILEGROWTH=1000MB
	) TO FILEGROUP FG_MinutePrice2;