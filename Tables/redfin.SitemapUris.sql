CREATE TABLE [redfin].[SitemapUris]
(
	[SitemapUriId] INT NOT NULL PRIMARY KEY identity(1,1),
	[SitemapUri] varchar(500) not null unique
)
