CREATE PROCEDURE [dbo].[MergeFinancialDataToTargetTable]

AS
  INSERT INTO FinancialData(DataPoint,FiscalPeriod,FiscalYear,Ticker,TimeFrame,Value)
SELECT fda.DataPoint
      ,fda.FiscalPeriod
      ,fda.FiscalYear
      ,fda.Ticker
      ,fda.TimeFrame
      ,avg(fda.Value) Value from(
SELECT	fds.DataPoint
		,fds.FiscalPeriod
		,fds.FiscalYear
		,fds.Ticker
    ,fd.Ticker AS TickerFromTargetTable
		,fds.TimeFrame
		,fds.Value from
		FinancialDataStaging as fds
		left join FinancialData as fd on
		fd.Ticker=fds.Ticker
		and fd.DataPoint=fds.DataPoint
		and fd.FiscalPeriod=fds.FiscalPeriod
		and fd.FiscalYear=fds.FiscalYear
		and fd.TimeFrame=fds.TimeFrame
		where fd.Ticker is NULL
) fda
GROUP BY fda.DataPoint,fda.FiscalPeriod,fda.FiscalYear,fda.Ticker,fda.TimeFrame
HAVING COUNT(*)=1

DELETE FROM FinancialDataStaging

RETURN 0
  