<Query Kind="Program">
  <Output>DataGrids</Output>
  <NuGetReference>Cobbler.Extensions</NuGetReference>
  <NuGetReference>CobblerETL.Framework</NuGetReference>
  <Namespace>Cobbler.Extensions.Collection</Namespace>
  <Namespace>Cobbler.Extensions.Functional</Namespace>
  <Namespace>Cobbler.Extensions.String</Namespace>
  <Namespace>Cobbler.Extensions.Time</Namespace>
  <Namespace>CobblerETL.Framework.Db</Namespace>
  <Namespace>System.Threading.Tasks</Namespace>
</Query>

async Task Main()
{

var tradingDays = Cobbler.Extensions.Time.DateTimeExtensions.GetTradingDays(new DateTime(2024,10,11));

var dates=DateTables.Where(dt =>dt.DateID<=tradingDays.D20.Start.ToDateOnly()&&dt.DateID>tradingDays.D20.End.ToDateOnly() && dt.WeekdayName!="Saturday" && dt.WeekdayName!="Sunday").ToList().Dump();
var taskList= new List<Task>();

   foreach (var d in dates){
		LoadCorrelations(d.DateID.ToDateTime(), 120);
			$"loaded 120 for {d.DateID}".Dump();
		}

}

public void LoadCorrelations(DateTime date, int offset=252)
{

var tradingDays = Cobbler.Extensions.Time.DateTimeExtensions.GetTradingDays(date);
var mostrecentDate=date.ToDateOnly();


var dateSelected = OffsetSelector(offset, tradingDays);
var tickersWhichAllHaveEqualCountOfEntriesForSpecifiedDateRange = DailySnapShotPricesMemOpts.Join(SecuritiesAbove1BMarketCap.Where(s=>s.MarketCap>15000000000), a => a.Ticker, b => b.Ticker, (a, b) => a).Where(t =>t.Date<=mostrecentDate && t.Date > dateSelected) //.Where(t => t.Date >dateSelected && t.Ticker=="INTC" | t.Ticker=="COKE" | t.Ticker=="TSLA")
	.GroupBy(t => t.Ticker, (a, b) => new { Ticker = a, Count = b.Count(), Data = b.Select(d => new { d.Date, Return = d.Return == 0 ? 0.0001 : d.Return }).OrderBy(d => d.Date).ToArray() })
	.GroupBy(t => t.Count)
	.OrderByDescending(t => t.Key)
	.Take(1)
	.OrderBy(t => t.Key)
	.ToList()[0];

var returnsData = tickersWhichAllHaveEqualCountOfEntriesForSpecifiedDateRange.ToDictionary(t => t.Ticker, t => t.Data);
var list = tickersWhichAllHaveEqualCountOfEntriesForSpecifiedDateRange.Select((t, i) => new { Index = i, Ticker = t.Ticker }).ToList();
var dataToSave = new List<CorrelationEntry>();


var returns = tickersWhichAllHaveEqualCountOfEntriesForSpecifiedDateRange.Select(t => t.Data.Select(v => v.Return.Value).ToArray());
var correlationMatrix = MathNet.Numerics.Statistics.Correlation.PearsonMatrix(returns);

for (int i = 0; i < correlationMatrix.RowCount; i++)
{



var tickera = list[i].Ticker;
for (int j = 0; j < correlationMatrix.ColumnCount; j++)
{
var tickerb = list[j].Ticker;
if (tickera.Equals(tickerb) == false)
{

var dataPointToInsert = new CorrelationEntry { Ticker_A = tickera, Ticker_B = tickerb, Date = date.ToDateOnly(), Correlation = Convert.ToDecimal(correlationMatrix[i, j] is Double.NaN ? 0.0001 : correlationMatrix[i, j]), Offset = offset };
dataToSave.Add(dataPointToInsert);

}
}


}
	var batchedData = dataToSave.Batch(500000).ToList();
	Parallel.ForEach(batchedData, a =>
	{
		a.BulkInsert(1200, true, "ptf.SecurityCorrelation", Cobbler.Extensions.Config.Connections.CobblerMarketDataConnectionString);
		$"{a.Count()} inserted.".Dump();
	});
		
}

public class CorrelationEntry
{
	public string Ticker_A { get; set; }
	public string Ticker_B { get; set; }
	public DateOnly Date { get; set; }
	public decimal Correlation { get; set; }
	public int Offset {get;set;}
}
public DateOnly OffsetSelector(int offset, TradingDays td) {
	if (offset==252)
	{
		return td.D252.End.ToDateOnly();
	}
	if (offset == 120)
	{
		return td.D120.End.ToDateOnly();
	}
	if (offset == 60)
	{
		return td.D60.End.ToDateOnly();
	}
	if (offset == 20)
	{
		return td.D20.End.ToDateOnly();
	}
	if (offset == 10)
	{
		return td.D10.End.ToDateOnly();
	}
	throw new Exception("Wrong offset provided");
}


// You can define other methods, fields, classes and namespaces here
