CREATE VIEW [dbo].[FinvizETFSView]
	AS 
	SELECT
  FinvizSnapshot.Ticker
 ,FinvizSnapshot.Company
 ,FinvizSnapshot.Sector
 ,FinvizSnapshot.Industry
 ,FinvizSnapshot.AssetType
 ,FinvizSnapshot.ActivePassive
 ,FinvizSnapshot.TotalHoldings
 ,FinvizSnapshot.AssetsUnderManagement
 ,FinvizSnapshot.NetAssetValue
 ,FinvizSnapshot.NetAssetValuePercent
 ,FinvizSnapshot.NetFlows1Month
 ,FinvizSnapshot.NetFlowsPercent1Month
 ,FinvizSnapshot.NetFlows3Month
 ,FinvizSnapshot.NetFlowsPercent3Month
 ,FinvizSnapshot.NetFlowsYTD
 ,FinvizSnapshot.NetFlowsPercentYTD
 ,FinvizSnapshot.NetFlows1Year
 ,FinvizSnapshot.Tags
FROM dbo.FinvizSnapshot
WHERE FinvizSnapshot.Industry = 'Exchange Traded Fund'
