/*
View: vw_WeeklyPriceSummary
Purpose: Collapses daily stock price data into weekly summaries with opening and closing prices
Description: 
    - Takes the opening price from the first trading day of each week
    - Takes the closing price from the last trading day of each week
    - Groups data by Ticker, Week, and Year
    - Useful for weekly technical analysis and reduced granularity reporting

Columns:
    - Ticker: Stock symbol
    - Date: First trading date of the week
    - Week: Week number within the year
    - Year: Calendar year
    - Open: Opening price from first trading day of week
    - Close: Closing price from last trading day of week

Data Sources:
    - pgon.DailySnapShotPricesMemOpt: Daily stock price snapshots
    - DateTable: Date dimension table with week/month/year breakdowns

Notes:
    - Currently filtered to 'intc' ticker only - modify WHERE clause for other tickers
    - Handles weeks with missing trading days (holidays, weekends)
    - Row numbers used to identify first/last trading days within each week
    - Can be extended to include High/Low prices for full OHLC data
    */
    Create View CollapsedWeeklyPrices
    as
WITH DailyData AS (
    SELECT 
        d.*,
        dt.Week,
        dt.Month,
        dt.Year,
        ROW_NUMBER() OVER (PARTITION BY d.Ticker, dt.Week, dt.Year ORDER BY d.Date) as TickerRowNum,
        ROW_NUMBER() OVER (PARTITION BY d.Ticker, dt.Week, dt.Year ORDER BY d.Date DESC) as ReverseRowNum
    FROM pgon.DailySnapShotPricesMemOpt d
    JOIN DateTable dt ON dt.DateID = d.Date

),
WeeklyCollapsed AS (
    SELECT 
        Ticker,
        Week,
        Year,
        MIN(Date) as Date, -- First trading day of the week
        MAX(CASE WHEN TickerRowNum = 1 THEN [Open] END) as [Open],
        MAX(CASE WHEN ReverseRowNum = 1 THEN [Close] END) as [Close]
    FROM DailyData
    GROUP BY Ticker, Week, Year
)
SELECT 
    Ticker,
    Date,
    Week,
    Year,
    [Open],
    [Close],
     LOG([Close] / [Open]) as LogReturn
FROM WeeklyCollapsed
