CREATE PARTITION SCHEME [PS_MinutePrice]
	AS PARTITION [PARTF_MinuteTrade]
	TO ([FG_MinutePrice], [FG_MinutePrice2], [FG_MinutePrice])
