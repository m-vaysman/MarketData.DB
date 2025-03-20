CREATE TABLE dbo.InvescoEtfs (
    Ticker NVARCHAR(10) NOT NULL primary key,
  Products NVARCHAR(255) NOT NULL,
  
    Inception DATE NOT NULL,
    GrossExpenseRatio FLOAT  NULL,
    YTD FLOAT NULL,
    OneYear FLOAT NULL,
    ThreeYear FLOAT NULL,
    FiveYear FLOAT NULL,
    TenYear FLOAT NULL,
    SinceInception FLOAT NULL,
    Category NVARCHAR(50)  NULL,
    SubCategory NVARCHAR(50)  NULL,
    CreatedOn DATE default(GETDATE()) not null
);