<Query Kind="Program">
  <Output>DataGrids</Output>
  <NuGetReference>Cobbler.CommonObjects</NuGetReference>
  <NuGetReference>Cobbler.Extensions</NuGetReference>
  <NuGetReference>CobblerETL.Framework</NuGetReference>
  <Namespace>Cobbler.Extensions.Time</Namespace>
  <Namespace>CobblerETL.Framework.Db</Namespace>
  <Namespace>Microsoft.Data.SqlClient</Namespace>
</Query>

void Main()
{
    var connString = Cobbler.Extensions.Config.Connections.CobblerMarketDataConnectionString;
    var paths = Directory.EnumerateFiles(@"G:\Polygon\MinuteAggregates\Extracted").ToList();

    Console.WriteLine($"Found {paths.Count} files to process");

    foreach (var path in paths)
    {
        try
        {
            var sw = System.Diagnostics.Stopwatch.StartNew();

            Console.WriteLine($"Reading {Path.GetFileName(path)}");
            var text = File.ReadAllText(path);

            Console.WriteLine("Parsing CSV");
            var rows = Cobbler.Extensions.Csv.CsvExtensions
                .ToPocos<MinutePriceCsv>(text, true)
                .Select(r =>
                {
                    var fullDt = Cobbler.Extensions.Time.DateTimeExtensions
                        .ConvertUnixTimeStampToDateTime(r.window_start / 1000000, UnixTimestampType.Milliseconds);

                    return new
                    {
                        Date = fullDt.Date,
                        DateTime = fullDt,
                        Ticker = r.ticker,
                        Volume = r.volume,
                        Open = r.open,
                        Close = r.close,
                        High = r.high,
                        Low = r.low,
                        Window_Start = r.window_start,
                        Transactions = r.transactions
                    };
                })
                .OrderBy(r => r.Date)
                .ThenBy(r => r.Ticker)
                .ThenBy(r => r.DateTime)
                .ToList();

            Console.WriteLine($"Parsed {rows.Count:N0} rows, inserting...");

            var dt = new DataTable();
            dt.Columns.Add("Date", typeof(System.DateTime));
            dt.Columns.Add("DateTime", typeof(System.DateTime));
            dt.Columns.Add("Ticker", typeof(string));
            dt.Columns.Add("Volume", typeof(double));
            dt.Columns.Add("Open", typeof(double));
            dt.Columns.Add("Close", typeof(double));
            dt.Columns.Add("High", typeof(double));
            dt.Columns.Add("Low", typeof(double));
            dt.Columns.Add("Window_Start", typeof(long));
            dt.Columns.Add("Transactions", typeof(int));

            foreach (var r in rows)
            {
                dt.Rows.Add(r.Date, r.DateTime, r.Ticker, r.Volume,
                    r.Open, r.Close, r.High, r.Low, r.Window_Start, r.Transactions);
            }

            using (var conn = new SqlConnection(connString))
            {
				conn.Open();
				using (var bulk = new SqlBulkCopy(conn, SqlBulkCopyOptions.TableLock, null))
				{
					bulk.DestinationTableName = "[pgon].[MinutePrice]";
					bulk.BatchSize = 100000;
					bulk.BulkCopyTimeout = 1200;

					bulk.ColumnMappings.Add("Date", "Date");
					bulk.ColumnMappings.Add("DateTime", "DateTime");
					bulk.ColumnMappings.Add("Ticker", "Ticker");
					bulk.ColumnMappings.Add("Volume", "Volume");
					bulk.ColumnMappings.Add("Open", "Open");
					bulk.ColumnMappings.Add("Close", "Close");
					bulk.ColumnMappings.Add("High", "High");
					bulk.ColumnMappings.Add("Low", "Low");
					bulk.ColumnMappings.Add("Window_Start", "Window_Start");
					bulk.ColumnMappings.Add("Transactions", "Transactions");

					bulk.WriteToServer(dt);
				}
			}

			sw.Stop();
			Console.WriteLine($"Done: {rows.Count:N0} rows in {sw.Elapsed.TotalSeconds:F1}s ({Path.GetFileName(path)})");
			// File.Delete(path);
		}
		catch (Exception e)
		{
			Console.WriteLine($"Error on {Path.GetFileName(path)}: {e.Message}");
		}
	}

	Console.WriteLine("All files complete");
}

public class MinutePriceCsv
{
	public string ticker { get; set; }
	public double volume { get; set; }
	public double open { get; set; }
	public double close { get; set; }
	public double high { get; set; }
	public double low { get; set; }
	public long window_start { get; set; }
	public int transactions { get; set; }
}