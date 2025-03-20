CREATE TABLE [dbo].[DailyVolumeSpikes]
(
	[Id] INT NOT NULL PRIMARY KEY identity(1,1),
	Ticker nvarchar(10) not null,
	[Date] Date not null,
	Volume float not null,
	VolumeAvg float,
	PercentAboveAvg float not null,
    MarketCap float not null
)
