CREATE TABLE [nyfed].[SecLendingOperations]
(
	[SecLendingOperationsId] INT NOT NULL PRIMARY KEY Identity(1,1), 
    [OperationId] VARCHAR(500) NULL, 
    [AuctionStatus] VARCHAR(500) NULL, 
    [OperationType] VARCHAR(500) NULL, 
    [SettlementDate] DATE NULL, 
    [MaturityDate] DATE NULL, 
    [ReleaseTime] VARCHAR(500) NULL, 
    [CloseTime] VARCHAR(500) NULL, 
    [Note] VARCHAR(500) NULL, 
    [LastUpdated] DATETIME NULL, 
    [TotalParAmtSubmitted] FLOAT NULL, 
    [TotalParAmtAccepted] FLOAT NULL,
	
)
