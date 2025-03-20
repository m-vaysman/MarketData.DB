CREATE TABLE InvescoEtfHoldings (
    InvescoEtfHoldings int not null primary key identity(1,1),
    FundTicker NVARCHAR(10)  NULL,
    SecurityIdentifier NVARCHAR(50)  NULL,
    HoldingTicker NVARCHAR(50)  NULL,
    SharesParValue BIGINT  NULL,
    MarketValue FLOAT  NULL,
    Weight FLOAT  NULL,
    Name NVARCHAR(255)  NULL,
    ClassOfShares NVARCHAR(50)  NULL,
    Sector NVARCHAR(50)  NULL,
    Date DATE  NULL,
    CreatedOn DATE default(getdate()) not null
);