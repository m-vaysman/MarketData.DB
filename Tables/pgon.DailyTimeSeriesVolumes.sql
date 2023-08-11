CREATE TABLE [pgon].[DailyTimeSeriesVolumes]
(
    [Id] BIGINT NOT NULL PRIMARY KEY identity(1,1),
	[Ticker] varchar(50) not null,
	[Volume] float not null,
	[VolumeWeighted] float not null,
	[AverageVolume] float not null,
	[TimeStamp] DateTime not null
)




GO

CREATE INDEX [IX_DailyTimeSeriesVolumes_Column] ON [pgon].[DailyTimeSeriesVolumes] ([Ticker]) include (Volume,VolumeWeighted,AverageVolume,[TimeStamp])

GO
CREATE INDEX [IX_DailyTimeSeriesVolumes_Column3] ON [pgon].[DailyTimeSeriesVolumes] ([TimeStamp]) include (Ticker,Volume,VolumeWeighted,AverageVolume)

GO
CREATE INDEX [IX_DailyTimeSeriesVolumes_Column2] ON [pgon].[DailyTimeSeriesVolumes] ([Ticker],[TimeStamp]) include (Volume,VolumeWeighted,AverageVolume)
