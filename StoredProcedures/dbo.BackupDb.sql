CREATE PROCEDURE [dbo].[BackupDb]

AS
	

-- Define backup options
DECLARE @BackupPath NVARCHAR(500)
SET @BackupPath = 'D:\Backup\SqlServer' -- Specify the path where you want to store the backup file

DECLARE @BackupFileName NVARCHAR(500)
SET @BackupFileName = @BackupPath + 'YourDatabaseName_backup_' + REPLACE(CONVERT(NVARCHAR(50), GETDATE(), 20), ':', '-') + '.bak'

-- Perform the database backup
BACKUP DATABASE [MarketData] 
TO DISK = @BackupFileName 
WITH FORMAT, 
     MEDIANAME = 'SQLServerBackups', 
     NAME = 'Full Backup of YourDatabaseName';

RETURN 0
