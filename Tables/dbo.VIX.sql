CREATE TABLE [dbo].[VIX]
(
	[VIXId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[Date] DATE NOT NULL UNIQUE,
	[Open] float NOT NULL,
	[High] float NOT NULL,
	[Low] float NOT NULL,
	[Close] float NOT NULL 
    
)
