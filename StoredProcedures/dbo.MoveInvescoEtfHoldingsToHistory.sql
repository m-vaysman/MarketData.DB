CREATE PROCEDURE [dbo].[MoveInvescoEtfHoldingsToHistory]
	
AS
	INSERT INTO [dbo].[InvescoEtfHoldingsHistory]
           ( [FundTicker]
           ,[SecurityIdentifier]
           ,[HoldingTicker]
           ,[SharesParValue]
           ,[MarketValue]
           ,[Weight]
           ,[Name]
           ,[ClassOfShares]
           ,[Sector]
           ,[Date]
        )
     select 
           FundTicker 
           ,SecurityIdentifier
           ,HoldingTicker 
           ,SharesParValue
           ,MarketValue
		   ,[Weight]
           ,[Name]
           ,ClassOfShares
           ,Sector
           ,[Date]
		   from dbo.InvescoEtfHoldings

        

           delete from dbo.InvescoEtfHoldings 
           DBCC CHECKIDENT ('InvescoEtfHoldings', RESEED, 0);
           
GO

