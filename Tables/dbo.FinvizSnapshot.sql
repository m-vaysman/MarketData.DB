CREATE TABLE dbo.FinvizSnapshot
(
    -- ============================================================
    -- FinvizRow base properties
    -- ============================================================

    -- === Identity / Basic ===
    No                          INT             NULL,
    Ticker                      NVARCHAR(20)    NOT NULL,
    Company                     NVARCHAR(200)   NULL,
    [Index]                     NVARCHAR(50)    NULL,
    Sector                      NVARCHAR(100)   NULL,
    Industry                    NVARCHAR(200)   NULL,
    Country                     NVARCHAR(100)   NULL,
    Exchange                    NVARCHAR(50)    NULL,

    -- === Valuation / Ratios ===
    MarketCap                   FLOAT           NULL,
    PE                          FLOAT           NULL,
    ForwardPE                   FLOAT           NULL,
    PEG                         FLOAT           NULL,
    PS                          FLOAT           NULL,
    PB                          FLOAT           NULL,
    PCash                       FLOAT           NULL,
    PFreeCashFlow               FLOAT           NULL,
    BookPerShare                FLOAT           NULL,
    CashPerShare                FLOAT           NULL,

    -- === Dividends ===
    Dividend                    FLOAT           NULL,
    DividendYield               FLOAT           NULL,
    DividendTTM                 FLOAT           NULL,
    DividendExDate              DATE            NULL,
    DividendGrowth1Year         FLOAT           NULL,
    DividendGrowth3Years        FLOAT           NULL,
    DividendGrowth5Years        FLOAT           NULL,
    PayoutRatio                 FLOAT           NULL,

    -- === EPS / Sales ===
    EPSTTM                      FLOAT           NULL,
    EPSNextQ                    FLOAT           NULL,
    EPSGrowthThisYear           FLOAT           NULL,
    EPSGrowthNextYear           FLOAT           NULL,
    EPSGrowthPast3Years         FLOAT           NULL,
    EPSGrowthPast5Years         FLOAT           NULL,
    EPSGrowthNext5Years         FLOAT           NULL,
    SalesGrowthPast3Years       FLOAT           NULL,
    SalesGrowthPast5Years       FLOAT           NULL,
    EPSQoQGrowth                FLOAT           NULL,
    EPSYoYTTM                   FLOAT           NULL,
    SalesYoYTTM                 FLOAT           NULL,

    -- === Income / Surprises ===
    Sales                       FLOAT           NULL,
    Income                      FLOAT           NULL,
    EPSSurprise                 FLOAT           NULL,
    RevenueSurprise             FLOAT           NULL,

    -- === Enterprise / Shares ===
    EnterpriseValue             FLOAT           NULL,
    EVToEBITDA                  FLOAT           NULL,
    SharesOutstanding           FLOAT           NULL,
    SharesFloat                 FLOAT           NULL,
    FloatPercent                FLOAT           NULL,

    -- === Ownership / Short ===
    InsiderOwnership            FLOAT           NULL,
    InsiderTransactions         FLOAT           NULL,
    InstitutionalOwnership      FLOAT           NULL,
    InstitutionalTransactions   FLOAT           NULL,
    ShortFloat                  FLOAT           NULL,
    ShortRatio                  FLOAT           NULL,
    ShortInterest               FLOAT           NULL,

    -- === Profitability / Leverage ===
    ReturnOnAssets              FLOAT           NULL,
    ReturnOnEquity              FLOAT           NULL,
    ReturnOnInvestedCapital     FLOAT           NULL,
    CurrentRatio                FLOAT           NULL,
    QuickRatio                  FLOAT           NULL,
    LTDebtToEquity              FLOAT           NULL,
    TotalDebtToEquity           FLOAT           NULL,
    GrossMargin                 FLOAT           NULL,
    OperatingMargin             FLOAT           NULL,
    ProfitMargin                FLOAT           NULL,

    -- === Performance (fractions) ===
    Performance1Min             FLOAT           NULL,
    Performance2Min             FLOAT           NULL,
    Performance3Min             FLOAT           NULL,
    Performance5Min             FLOAT           NULL,
    Performance10Min            FLOAT           NULL,
    Performance15Min            FLOAT           NULL,
    Performance30Min            FLOAT           NULL,
    Performance1Hour            FLOAT           NULL,
    Performance2Hours           FLOAT           NULL,
    Performance4Hours           FLOAT           NULL,
    PerformanceWeek             FLOAT           NULL,
    PerformanceMonth            FLOAT           NULL,
    PerformanceQuarter          FLOAT           NULL,
    PerformanceHalfYear         FLOAT           NULL,
    PerformanceYTD              FLOAT           NULL,
    PerformanceYear             FLOAT           NULL,
    Performance3Years           FLOAT           NULL,
    Performance5Years           FLOAT           NULL,
    Performance10Years          FLOAT           NULL,

    -- === Technicals ===
    Beta                        FLOAT           NULL,
    AverageTrueRange            FLOAT           NULL,
    VolatilityWeek              FLOAT           NULL,
    VolatilityMonth             FLOAT           NULL,
    SMA20Day                    FLOAT           NULL,
    SMA50Day                    FLOAT           NULL,
    SMA200Day                   FLOAT           NULL,
    High50Day                   FLOAT           NULL,
    Low50Day                    FLOAT           NULL,
    High52Week                  FLOAT           NULL,
    Low52Week                   FLOAT           NULL,
    Range52Week                 NVARCHAR(50)    NULL,
    AllTimeHigh                 FLOAT           NULL,
    AllTimeLow                  FLOAT           NULL,
    RSI14                       FLOAT           NULL,

    -- === Dates / Flags ===
    EarningsDate                DATE            NULL,
    IPODate                     DATE            NULL,
    Optionable                  NVARCHAR(10)    NULL,
    Shortable                   NVARCHAR(10)    NULL,

    -- === Intraday (price/volume) ===
    ChangeFromOpen              FLOAT           NULL,
    Gap                         FLOAT           NULL,
    AnalystRecom                FLOAT           NULL,
    AverageVolume               FLOAT           NULL,
    RelativeVolume              FLOAT           NULL,
    Volume                      FLOAT           NULL,
    Trades                      FLOAT           NULL,
    TargetPrice                 FLOAT           NULL,
    PrevClose                   FLOAT           NULL,
    [Open]                      FLOAT           NULL,
    High                        FLOAT           NULL,
    Low                         FLOAT           NULL,
    Price                       FLOAT           NULL,
    Change                      FLOAT           NULL,

    -- === News ===
    NewsTime                    DATETIME2       NULL,
    NewsURL                     NVARCHAR(500)   NULL,
    NewsTitle                   NVARCHAR(500)   NULL,

    -- === ETF / Category metadata ===
    SingleCategory              NVARCHAR(100)   NULL,
    AssetType                   NVARCHAR(50)    NULL,
    ETFType                     NVARCHAR(100)   NULL,
    SectorTheme                 NVARCHAR(100)   NULL,
    Region                      NVARCHAR(100)   NULL,
    ActivePassive               NVARCHAR(20)    NULL,

    -- === ETF metrics ===
    NetExpenseRatio             FLOAT           NULL,
    TotalHoldings               FLOAT           NULL,
    AssetsUnderManagement       FLOAT           NULL,
    NetAssetValue               FLOAT           NULL,
    NetAssetValuePercent        FLOAT           NULL,
    NetFlows1Month              FLOAT           NULL,
    NetFlowsPercent1Month       FLOAT           NULL,
    NetFlows3Month              FLOAT           NULL,
    NetFlowsPercent3Month       FLOAT           NULL,
    NetFlowsYTD                 FLOAT           NULL,
    NetFlowsPercentYTD          FLOAT           NULL,
    NetFlows1Year               FLOAT           NULL,
    NetFlowsPercent1Year        FLOAT           NULL,
    Return1Year                 FLOAT           NULL,
    Return3Year                 FLOAT           NULL,
    Return5Year                 FLOAT           NULL,
    Return10Year                FLOAT           NULL,
    ReturnSinceInception        FLOAT           NULL,

    -- === Other ===
    Tags                        NVARCHAR(500)   NULL,

    -- ============================================================
    -- FinvizRowExtended: Calculated trading metrics (materialized)
    -- ============================================================

    -- Volatility & Price Position
    PriceCompressionScore       FLOAT           NULL,
    VolatilityRegime            NVARCHAR(20)    NULL,   -- Low / Medium / High / Spike
    DistanceSMA50               FLOAT           NULL,
    PositionIn52WeekRange       FLOAT           NULL,

    -- Momentum & Trend Detection
    TrendDirection              NVARCHAR(20)    NULL,   -- Up / Down / Sideways
    TrendStage                  NVARCHAR(30)    NULL,   -- 1 Base / 2 Advancing / 3 Distribution / 4 Declining
    VolumeConfirmation          FLOAT           NULL,

    -- Support & Resistance
    SRLevel                     NVARCHAR(20)    NULL,   -- Resistance / Support / Mid-range
    BreakoutSignal              NVARCHAR(20)    NULL,   -- Breakout / Breakdown / None

    -- Overbought / Oversold
    RSIExtreme                  NVARCHAR(20)    NULL,   -- Overbought / Oversold / Neutral
    ConsecutiveTrend            INT             NULL,

    -- Earnings & Fundamental Risk
    DividendSafety              NVARCHAR(10)    NULL,   -- Safe / Risky
    QualityGrade                NVARCHAR(10)    NULL,   -- Grade A / B / C / D

    -- Trade Setup Filters
    LiquidityStatus             NVARCHAR(20)    NULL,   -- Excellent / Good / Tradeable / Illiquid / Unknown
    HighMomentum                BIT             NULL,
    MeanReversionCandidate      BIT             NULL,
    ValueSafety                 BIT             NULL,

    -- Advanced Technical Indicators
    WilliamsPercentR            FLOAT           NULL,
    CCITT                       FLOAT           NULL,
    StochasticOscillatorFast    FLOAT           NULL,
    BollingerBandPosition       FLOAT           NULL,
    MomentumDirection           NVARCHAR(20)    NULL,   -- Strong Up / Strong Down / Uptrend / Downtrend / Sideways / Volatility / Mixed

    -- Sentiment & Volume Analysis
    ShortInterestSignal         NVARCHAR(30)    NULL,   -- High Bearish / Moderate Bearish / Bullish / Neutral
    VolumeSurge                 BIT             NULL,
    MoneyFlow                   NVARCHAR(30)    NULL,   -- Strong Inflow / Strong Outflow / Mild Inflow / Mild Outflow / Balanced

    -- Options & Fundamental Timing
    HighOptionsActivity         BIT             NULL,

    -- Sector & Relative Strength
    RelativeStrength            NVARCHAR(30)    NULL,   -- Strong Outperformer / Outperformer / Underperformer / Strong Underperformer / Market Tracking
    TrendStrengthScore          FLOAT           NULL,

    -- Risk Management
    RiskAdjustedPerformance     FLOAT           NULL,
    LowVolatilityQuality        BIT             NULL,
    HighBetaMomentum            BIT             NULL,

    -- Fundamental Timing Signals
    EarningsProximity           NVARCHAR(50)    NULL,   -- Earnings Week / Earnings Days / Pre-Earnings Runup / Post-Earnings Drift / No Significant Event
    GrowthStock                 BIT             NULL,
    ValueTrapAvoidSignal        BIT             NULL,

    -- Advanced Combined Signals
    MomentumConvergence         NVARCHAR(40)    NULL,   -- Strong Bullish Convergence / Moderate Bullish / Strong Bearish Convergence / ...
    TechnicalSetupScore         FLOAT           NULL,
    RiskScore                   FLOAT           NULL,
    AdvancedMeanReversion       BIT             NULL,
    MomentumBurst               BIT             NULL,
    DeepValueTrap               BIT             NULL,
    BreakoutConfirmation        BIT             NULL,

    -- Fundamental Classifications
    MarketCapCategory           NVARCHAR(20)    NULL,   -- Mega-cap / Large-cap / Mid-cap / Small-cap / Micro-cap / Nano-cap

    -- Alias (materialized for convenience)
    DebtToEquity                FLOAT           NULL,   -- = LTDebtToEquity

    -- ============================================================
    -- FinvizRowExtended: Enumerated boolean flags (materialized)
    -- ============================================================
    IsUpTrend                           BIT     NOT NULL DEFAULT 0,
    IsDownTrend                         BIT     NOT NULL DEFAULT 0,
    IsInBreakout                        BIT     NOT NULL DEFAULT 0,
    IsOverSold                          BIT     NOT NULL DEFAULT 0,
    IsOverBought                        BIT     NOT NULL DEFAULT 0,
    IsQuality                           BIT     NOT NULL DEFAULT 0,
    IsHighRsi                           BIT     NOT NULL DEFAULT 0,
    IsLowRsi                            BIT     NOT NULL DEFAULT 0,
    IsWilliamsOversold                  BIT     NOT NULL DEFAULT 0,
    IsWilliamsOverbought                BIT     NOT NULL DEFAULT 0,
    IsHighStochastic                    BIT     NOT NULL DEFAULT 0,
    IsLowStochastic                     BIT     NOT NULL DEFAULT 0,
    IsOutsideBollinger                  BIT     NOT NULL DEFAULT 0,
    IsStrongMomentum                    BIT     NOT NULL DEFAULT 0,
    IsBearishShortInterest              BIT     NOT NULL DEFAULT 0,
    IsVolumeSurgeActive                 BIT     NOT NULL DEFAULT 0,
    IsSmartMoneyInflow                  BIT     NOT NULL DEFAULT 0,
    IsOutperformer                      BIT     NOT NULL DEFAULT 0,
    IsLowVolatilityStock                BIT     NOT NULL DEFAULT 0,
    IsHighBetaStock                     BIT     NOT NULL DEFAULT 0,
    IsNearEarnings                      BIT     NOT NULL DEFAULT 0,
    IsGrowthCandidate                   BIT     NOT NULL DEFAULT 0,
    IsValueTrapSafe                     BIT     NOT NULL DEFAULT 0,
    IsStrongBullishConvergence          BIT     NOT NULL DEFAULT 0,
    IsStrongBearishConvergence          BIT     NOT NULL DEFAULT 0,
    IsBreakoutConfirmed                 BIT     NOT NULL DEFAULT 0,
    IsMomentumBurstActive               BIT     NOT NULL DEFAULT 0,
    IsAdvancedMeanReversionSignal       BIT     NOT NULL DEFAULT 0,
    IsDeepValueTrap                     BIT     NOT NULL DEFAULT 0,

    -- ============================================================
    -- FinvizRowExtended: Ranking columns
    -- ============================================================
    RANK_Performance1Min                INT     NOT NULL DEFAULT 0,
    RANK_Performance2Min                INT     NOT NULL DEFAULT 0,
    RANK_Performance3Min                INT     NOT NULL DEFAULT 0,
    RANK_Performance5Min                INT     NOT NULL DEFAULT 0,
    RANK_Performance10Min               INT     NOT NULL DEFAULT 0,
    RANK_Performance15Min               INT     NOT NULL DEFAULT 0,
    RANK_Performance30Min               INT     NOT NULL DEFAULT 0,
    RANK_Performance1Hour               INT     NOT NULL DEFAULT 0,
    RANK_Performance2Hours              INT     NOT NULL DEFAULT 0,
    RANK_Performance4Hours              INT     NOT NULL DEFAULT 0,
    RANK_PerformanceWeek                INT     NOT NULL DEFAULT 0,
    RANK_PerformanceMonth               INT     NOT NULL DEFAULT 0,
    RANK_PerformanceQuarter             INT     NOT NULL DEFAULT 0,
    RANK_PerformanceHalfYear            INT     NOT NULL DEFAULT 0,
    RANK_PerformanceYTD                 INT     NOT NULL DEFAULT 0,
    RANK_PerformanceYear                INT     NOT NULL DEFAULT 0,
    RANK_Performance3Years              INT     NOT NULL DEFAULT 0,
    RANK_Performance5Years              INT     NOT NULL DEFAULT 0,
    RANK_Performance10Years             INT     NOT NULL DEFAULT 0,
    RANK_RiskAdjustedPerformance        INT     NOT NULL DEFAULT 0,

    RANK_Beta_Industry                  INT     NOT NULL DEFAULT 0,
    RANK_Beta_Sector                    INT     NOT NULL DEFAULT 0,
    RANK_PS_Industry                    INT     NOT NULL DEFAULT 0,
    RANK_PS_Sector                      INT     NOT NULL DEFAULT 0,
    RANK_PB_Industry                    INT     NOT NULL DEFAULT 0,
    RANK_PB_Sector                      INT     NOT NULL DEFAULT 0,
    RANK_PE_Industry                    INT     NOT NULL DEFAULT 0,
    RANK_PE_Sector                      INT     NOT NULL DEFAULT 0,
    RANK_ForwardPE_Industry             INT     NOT NULL DEFAULT 0,
    RANK_ForwardPE_Sector               INT     NOT NULL DEFAULT 0,
    RANK_PFreeCashFlow_Industry         INT     NOT NULL DEFAULT 0,
    RANK_PFreeCashFlow_Sector           INT     NOT NULL DEFAULT 0,
    RANK_ReturnOnEquity_Industry        INT     NOT NULL DEFAULT 0,
    RANK_ReturnOnEquity_Sector          INT     NOT NULL DEFAULT 0,
    RANK_ReturnOnAssets_Industry        INT     NOT NULL DEFAULT 0,
    RANK_ReturnOnAssets_Sector          INT     NOT NULL DEFAULT 0,
    RANK_ReturnOnInvestedCapital_Industry INT   NOT NULL DEFAULT 0,
    RANK_ReturnOnInvestedCapital_Sector INT     NOT NULL DEFAULT 0,

    -- === Industry/Sector comparison values ===
    PE_Industry                         FLOAT   NULL,
    PE_Sector                           FLOAT   NULL,
    ForwardPE_Industry                  FLOAT   NULL,
    ForwardPE_Sector                    FLOAT   NULL,

    -- === Metadata ===
    SnapshotDate                DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_FinvizSnapshot PRIMARY KEY CLUSTERED (Ticker)
);
GO

-- Useful indexes for common queries
CREATE NONCLUSTERED INDEX IX_FinvizSnapshot_Sector       ON dbo.FinvizSnapshot (Sector)         INCLUDE (Ticker, Industry);
GO
CREATE NONCLUSTERED INDEX IX_FinvizSnapshot_Industry     ON dbo.FinvizSnapshot (Industry)        INCLUDE (Ticker, Sector);
GO
CREATE NONCLUSTERED INDEX IX_FinvizSnapshot_TrendDir     ON dbo.FinvizSnapshot (TrendDirection)   INCLUDE (Ticker, TrendStage);
GO
CREATE NONCLUSTERED INDEX IX_FinvizSnapshot_MarketCap    ON dbo.FinvizSnapshot (MarketCapCategory) INCLUDE (Ticker);
GO