CREATE TABLE dbo.PairsAnalysis (
    PairsAnalysisId     INT IDENTITY PRIMARY KEY,
    RunDate             DATE NOT NULL,
    TickerA             NVARCHAR(10) NOT NULL,
    TickerB             NVARCHAR(10) NOT NULL,
    Corr_252d           FLOAT NULL,
    Corr_120d           FLOAT NULL,
    Corr_60d            FLOAT NULL,
    Corr_20d            FLOAT NULL,
    Corr_5d             FLOAT NULL,
    CorrDelta_Short_Long FLOAT NULL,       -- Corr_20d - Corr_252d (negative = diverging)
    SpreadZScore        FLOAT NULL,         -- current z-score of log price spread
    ZScore_5d_Chg       FLOAT NULL,         -- 5-day change in z-score (direction)
    SpreadMean_60d      FLOAT NULL,         -- rolling 60d mean of spread
    SpreadStdDev_60d    FLOAT NULL,         -- rolling 60d stdev of spread
    HalfLife            FLOAT NULL,         -- estimated mean reversion half-life in days
    Signal              NVARCHAR(20) NULL,  -- DIVERGING, CONVERGING, STABLE
    SicCodeA            NVARCHAR(10) NULL,
    SicCodeB            NVARCHAR(10) NULL,
    TimeStamp           DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT AK_PairsAnalysis_RunDate_Pair UNIQUE (RunDate, TickerA, TickerB)
);
go
CREATE INDEX IX_PairsAnalysis_RunDate ON dbo.PairsAnalysis (RunDate);
go
CREATE INDEX IX_PairsAnalysis_Signal ON dbo.PairsAnalysis (Signal, RunDate);
go
CREATE INDEX IX_PairsAnalysis_CorrDelta ON dbo.PairsAnalysis (CorrDelta_Short_Long, RunDate);
go
CREATE INDEX IX_PairsAnalysis_SpreadZScore ON dbo.PairsAnalysis (SpreadZScore, RunDate);