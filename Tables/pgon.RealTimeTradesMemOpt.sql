/*
The bucket count should be set to about two times the 
maximum expected number of distinct values in the 
index key, rounded up to the nearest power of two.
*/

CREATE TABLE [pgon].[RealTimeTradesMemOpt]
(
	[Id] BIGINT NOT NULL PRIMARY KEY NONCLUSTERED identity(1,1),
	
    Ticker NVARCHAR(10),          -- Corresponds to "sym"
    Exchange INT,                 -- Corresponds to "x"
    Price Float,         -- Corresponds to "p"
    Conditions nvarchar(50),
    Size INT,                     -- Corresponds to "s"
    Timestamp BIGINT,             -- Corresponds to "t"
    Quantity INT,                 -- Corresponds to "q"
    Zone INT,
    CreatedOn DateTime default(GetDate()), 
 

) WITH (MEMORY_OPTIMIZED = ON)

GO

/*
Do not change the database path or name variables.
Any sqlcmd variables will be properly substituted during 
build and deployment.
*/


   
