CREATE TABLE [dbo].[EtfHoldingsMap]
(
	[EtfHoldingsMapId] INT NOT NULL PRIMARY KEY identity(1,1),
	[Ticker] NVARCHAR(10) NOT NULL ,
	[Date] DATE NOT NULL, 
    CONSTRAINT [FK_EtfHoldingsMap_ToTable] FOREIGN KEY ([Ticker]) REFERENCES [dbo].[EtfReference]([Ticker])
)

	
