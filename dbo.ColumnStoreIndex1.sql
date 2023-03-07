CREATE COLUMNSTORE INDEX [ColumnStoreIndex1]
	ON [pgon].[DailySnapshotPrices]
	([Date],[Ticker],[High])
