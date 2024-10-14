CREATE TABLE [dbo].[TargetPrice]
(
	Ticker nvarchar(10) not null,
	[Date] Date not null,
	TargetPrice float default(0),
	CreatedOn Datetime not null, 
    CONSTRAINT [AK_TargetPrice_TickerDate] UNIQUE ([Ticker],[Date]) 
	
)
