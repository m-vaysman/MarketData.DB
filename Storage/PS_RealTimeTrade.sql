CREATE PARTITION SCHEME [PS_RealTimeTrade]
	AS PARTITION [PF_RealTimeTrade]
	TO ([FG_RealTimeTrade], [FG_RealTimeTrade2], [FG_RealTimeTrade3])
