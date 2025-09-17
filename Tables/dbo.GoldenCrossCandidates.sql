CREATE TABLE [dbo].[GoldenCrossCandidates]
(
	        GoldenCrossCandidatesId int not null identity(1,1),
            Ticker VARCHAR(50) NOT NULL,
            [Date] DATE NOT NULL,
            [Close] FLOAT NULL,
            Volume FLOAT NULL,
            SMA50 FLOAT NULL,
            SMA200 FLOAT NULL,
            VolSMA5 FLOAT NULL,
            PrevSMA50 FLOAT NULL,
            PrevSMA200 FLOAT NULL,
            PrevVolSMA5 FLOAT NULL,
            PrevClose FLOAT NULL
)
