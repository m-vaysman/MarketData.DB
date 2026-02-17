CREATE PROCEDURE [dbo].[GetSupportZones]

AS
	-- ==============================================================================
-- STRONG SUPPORT ZONES - Price Levels Unlikely to Break Below
-- ==============================================================================
-- This query identifies the strongest support levels where price is likely to hold
-- Focus: Areas where multiple bounces occurred with high volume
-- ==============================================================================

WITH RecentPriceAction AS (
    -- Get 1 year of price data
    SELECT 
        Ticker,
        Date,
        [Open],
        High,
        Low,
        [Close],
        Volume,
        -- Calculate daily range
        High - Low AS DailyRange,
        -- Previous day values
        LAG(Low, 1) OVER (PARTITION BY Ticker ORDER BY Date) AS Prev1Low,
        LAG(Low, 2) OVER (PARTITION BY Ticker ORDER BY Date) AS Prev2Low,
        LAG([Close], 1) OVER (PARTITION BY Ticker ORDER BY Date) AS PrevClose
    FROM pgon.DailySnapShotPricesMemOpt
    WHERE Date >= DATEADD(YEAR, -1, GETDATE())
        AND [Close] IS NOT NULL
),

-- Identify strong bullish reversal days (potential support confirmation)
SupportTests AS (
    SELECT 
        Ticker,
        Date,
        Low AS SupportLevel,
        [Close],
        Volume,
        DailyRange,
        -- Calculate bounce strength
        ([Close] - Low) / NULLIF(Low, 0) * 100 AS BouncePct,
        -- Volume ratio vs 20-day average
        Volume / AVG(Volume) OVER (
            PARTITION BY Ticker 
            ORDER BY Date 
            ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
        ) AS VolumeRatio
    FROM RecentPriceAction
    WHERE Low <= Prev1Low  -- Made a lower low
        AND Low <= Prev2Low
        AND [Close] > [Open]  -- Closed green (bullish)
        AND ([Close] - Low) / NULLIF(Low, 0) >= 0.015  -- At least 1.5% bounce from low
),

-- Group nearby support levels into zones (within 3%)
SupportZoneClusters AS (
    SELECT 
        Ticker,
        -- Create price clusters by rounding to 3% buckets
        ROUND(AVG(SupportLevel) / 0.97, 0) * 0.97 AS ZoneCenter,
        COUNT(*) AS TestCount,
        AVG(SupportLevel) AS AvgSupportLevel,
        MIN(SupportLevel) AS ZoneFloor,
        MAX(SupportLevel) AS ZoneCeiling,
        AVG(BouncePct) AS AvgBounceStrength,
        SUM(Volume) AS TotalVolume,
        AVG(VolumeRatio) AS AvgVolumeRatio,
        MAX(Date) AS MostRecentTest,
        MIN(Date) AS FirstTest,
        DATEDIFF(DAY, MIN(Date), MAX(Date)) AS ZoneAgeInDays
    FROM SupportTests
    GROUP BY 
        Ticker, 
        -- Group by 3% price buckets
        ROUND(SupportLevel / 3.0, 0)
    HAVING COUNT(*) >= 2  -- At least 2 tests of support
),

-- Get current price for each stock
LatestPrices AS (
    SELECT 
        Ticker,
        [Close] AS CurrentPrice,
        Date AS PriceDate,
        Volume AS CurrentVolume,
        ROW_NUMBER() OVER (PARTITION BY Ticker ORDER BY Date DESC) AS rn
    FROM pgon.DailySnapShotPricesMemOpt
    WHERE [Close] IS NOT NULL
)

-- Final Output: Ranked Support Zones
SELECT 
    sz.Ticker,
    lp.CurrentPrice,
    lp.PriceDate AS AsOfDate,
    sz.AvgSupportLevel AS SupportZonePrice,
    sz.ZoneFloor AS ZoneLow,
    sz.ZoneCeiling AS ZoneHigh,
    -- Key metrics
    sz.TestCount AS TimesTestedAndHeld,
    CAST(sz.AvgBounceStrength AS DECIMAL(8,2)) AS AvgBouncePct,
    CAST(sz.AvgVolumeRatio AS DECIMAL(8,2)) AS AvgVolumeVs20DayAvg,
    -- Distance calculations
    CAST((lp.CurrentPrice - sz.AvgSupportLevel) / NULLIF(lp.CurrentPrice, 0) * 100 AS DECIMAL(8,2)) AS DistanceFromSupportPct,
    CAST(lp.CurrentPrice - sz.AvgSupportLevel AS DECIMAL(10,2)) AS DistanceFromSupportDollars,
    -- Time factors
    sz.MostRecentTest,
    DATEDIFF(DAY, sz.MostRecentTest, GETDATE()) AS DaysSinceLastTest,
    sz.ZoneAgeInDays AS DaysOfEstablishedSupport,
    -- Support strength score (higher = stronger)
    CAST(
        (sz.TestCount * 15.0) +  -- More tests = stronger
        (sz.AvgBounceStrength * 2) +  -- Stronger bounces = stronger
        (sz.AvgVolumeRatio * 5) +  -- Higher volume = stronger
        (CASE WHEN sz.ZoneAgeInDays > 90 THEN 10 ELSE sz.ZoneAgeInDays / 9.0 END) +  -- Age bonus
        (CASE WHEN DATEDIFF(DAY, sz.MostRecentTest, GETDATE()) < 30 THEN 15 ELSE 0 END)  -- Recent test bonus
    AS DECIMAL(10,2)) AS SupportStrengthScore,
    -- Risk assessment
    CASE 
        WHEN (lp.CurrentPrice - sz.AvgSupportLevel) / NULLIF(lp.CurrentPrice, 0) < 0.05 THEN 'AT SUPPORT'
        WHEN (lp.CurrentPrice - sz.AvgSupportLevel) / NULLIF(lp.CurrentPrice, 0) < 0.10 THEN 'NEAR SUPPORT'
        WHEN (lp.CurrentPrice - sz.AvgSupportLevel) / NULLIF(lp.CurrentPrice, 0) < 0.20 THEN 'APPROACHING SUPPORT'
        ELSE 'FAR FROM SUPPORT'
    END AS ProximityStatus
FROM SupportZoneClusters sz
INNER JOIN LatestPrices lp ON sz.Ticker = lp.Ticker AND lp.rn = 1
WHERE lp.CurrentPrice>15 and sz.AvgSupportLevel < lp.CurrentPrice  -- Support must be below current price
    AND sz.AvgSupportLevel > lp.CurrentPrice * 0.70  -- Within 30% below current price
    AND sz.TestCount >= 2  -- Minimum 2 successful tests
ORDER BY 
    sz.Ticker,
    SupportStrengthScore DESC,
    DistanceFromSupportPct ASC;


-- ==============================================================================
-- USAGE EXAMPLES:
-- ==============================================================================

-- 1. Find strongest support for specific stocks:
/*
SELECT * FROM (... above query ...)
WHERE Ticker IN ('AAPL', 'MSFT', 'GOOGL')
    AND SupportStrengthScore > 50
ORDER BY SupportStrengthScore DESC;
*/

-- 2. Find stocks currently at or near major support:
/*
SELECT * FROM (... above query ...)
WHERE ProximityStatus IN ('AT SUPPORT', 'NEAR SUPPORT')
    AND SupportStrengthScore > 40
    AND TimesTestedAndHeld >= 3
ORDER BY SupportStrengthScore DESC;
*/

-- 3. Find support levels tested recently (last 30 days):
/*
SELECT * FROM (... above query ...)
WHERE DaysSinceLastTest <= 30
    AND TimesTestedAndHeld >= 3
ORDER BY Ticker, SupportStrengthScore DESC;
*/
RETURN 0
