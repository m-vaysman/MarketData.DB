CREATE VIEW [dbo].[SecLinks]
	AS SELECT dt.Month,dt.Day, dt.Year, dt.Quarter, CONCAT('https://www.sec.gov/files/dera/data/financial-statement-data-sets/', CAST(dt.Year AS nvarchar(4)), 'q', CAST(dt.Quarter AS nvarchar(1)), '.zip') AS SecFinancialStatementDataLink
FROM dbo.DateTable AS dt

	