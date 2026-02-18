<Query Kind="Program">
  <Namespace>System</Namespace>
  <Namespace>System.Collections.Generic</Namespace>
  <Namespace>System.Data</Namespace>
  <Namespace>System.Data.SqlClient</Namespace>
  <Namespace>System.Diagnostics</Namespace>
  <Namespace>System.IO</Namespace>
  <Namespace>System.IO.Compression</Namespace>
  <Namespace>System.Linq</Namespace>
</Query>

void Main()
{
	var sourceDir = @"G:\Polygon\Quotes";
	var connectionString = Cobbler.Extensions.Config.Connections.CobblerMarketDataConnectionString;
	const int batchSize = 500_000;
	const string tableName = "[pgon].[RealTimeQuotes]";

	var files = Directory.GetFiles(sourceDir, "*.gz")
		.Concat(Directory.GetFiles(sourceDir, "*.zip"))
		.OrderBy(f => f)
		.ToArray();

	Console.WriteLine($"Found {files.Length} files to process.");
	Console.WriteLine();

	var totalRows = 0L;
	var totalSw = Stopwatch.StartNew();

	for (int fileIndex = 0; fileIndex < files.Length; fileIndex++)
	{
		var file = files[fileIndex];
		var fileSw = Stopwatch.StartNew();
		var fileRows = 0L;

		Console.WriteLine($"[{fileIndex + 1}/{files.Length}] Processing: {Path.GetFileName(file)}");

		foreach (var stream in GetReadStreams(file))
		{
			using (stream)
			using (var reader = new StreamReader(stream))
			{
				var batch = new List<object[]>(batchSize);
				string line;
				bool isFirstLine = true;

				while ((line = reader.ReadLine()) != null)
				{
					if (isFirstLine)
					{
						isFirstLine = false;
						if (line.StartsWith("Ticker") || line.StartsWith("ticker"))
							continue;
					}

					var row = ParseLine(line);
					if (row != null)
					{
						batch.Add(row);

						if (batch.Count >= batchSize)
						{
							BulkInsert(connectionString, tableName, batch);
							fileRows += batch.Count;
							Console.WriteLine($"  Inserted batch: {batch.Count:N0} rows (file total: {fileRows:N0})");
							batch.Clear();
						}
					}
				}

				if (batch.Count > 0)
				{
					BulkInsert(connectionString, tableName, batch);
					fileRows += batch.Count;
					Console.WriteLine($"  Inserted final batch: {batch.Count:N0} rows (file total: {fileRows:N0})");
					batch.Clear();
				}
			}
		}

		fileSw.Stop();
		totalRows += fileRows;
		Console.WriteLine($"  Completed in {fileSw.Elapsed.TotalSeconds:F1}s | File rows: {fileRows:N0} | Running total: {totalRows:N0}");
		Console.WriteLine();
	}

	totalSw.Stop();
	Console.WriteLine("========================================");
	Console.WriteLine($"All files processed.");
	Console.WriteLine($"Total rows inserted: {totalRows:N0}");
	Console.WriteLine($"Total time: {totalSw.Elapsed}");
	Console.WriteLine();
	Console.WriteLine("REMINDER: Run the following to optimize the columnstore index:");
	Console.WriteLine("ALTER INDEX [CCI_RealTimeQuotes] ON [pgon].[RealTimeQuotes] REORGANIZE;");
}

IEnumerable<Stream> GetReadStreams(string filePath)
{
	var ext = Path.GetExtension(filePath).ToLowerInvariant();

	if (ext == ".gz")
	{
		var fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read, 64 * 1024);
		yield return new GZipStream(fs, CompressionMode.Decompress);
	}
	else if (ext == ".zip")
	{
		using (var archive = ZipFile.OpenRead(filePath))
		{
			foreach (var entry in archive.Entries)
			{
				if (entry.Length > 0)
				{
					var ms = new MemoryStream();
					using (var entryStream = entry.Open())
					{
						entryStream.CopyTo(ms);
					}
					ms.Position = 0;
					yield return ms;
				}
			}
		}
	}
}

object[] ParseLine(string line)
{
	var parts = line.Split(',');
	if (parts.Length < 14)
		return null;

	try
	{
		var ticker = parts[0].Trim();
		var askExchange = int.Parse(parts[1]);
		var askPrice = double.Parse(parts[2]);
		var askSize = double.Parse(parts[3]);
		var bidExchange = int.Parse(parts[4]);
		var bidPrice = double.Parse(parts[5]);
		var bidSize = double.Parse(parts[6]);
		var conditions = string.IsNullOrWhiteSpace(parts[7]) ? (object)DBNull.Value : parts[7].Trim();
		var indicators = string.IsNullOrWhiteSpace(parts[8]) ? (object)DBNull.Value : parts[8].Trim();
		var participantTimestamp = long.Parse(parts[9]);
		var sequenceNumber = long.Parse(parts[10]);
		var sipTimestamp = long.Parse(parts[11]);
		var tape = byte.Parse(parts[12]);
		var trfTimestamp = long.Parse(parts[13]);

		var date = DateTimeOffset.FromUnixTimeMilliseconds(participantTimestamp / 1_000_000).DateTime.Date;

		return new object[]
		{
			date,              // 0: Date
			ticker,            // 1: Ticker
			askExchange,       // 2: AskExchange
			askPrice,          // 3: AskPrice
			askSize,           // 4: AskSize
			bidExchange,       // 5: BidExchange
			bidPrice,          // 6: BidPrice
			bidSize,           // 7: BidSize
			conditions,        // 8: Conditions
			indicators,        // 9: Indicators
			participantTimestamp, // 10: ParticipantTimestamp
			sequenceNumber,    // 11: SequenceNumber
			sipTimestamp,      // 12: SipTimestamp
			tape,              // 13: Tape
			trfTimestamp       // 14: TrfTimestamp
		};
	}
	catch
	{
		return null;
	}
}

void BulkInsert(string connectionString, string tableName, List<object[]> batch)
{
	using (var connection = new SqlConnection(connectionString))
	{
		connection.Open();

		using (var bulkCopy = new SqlBulkCopy(connection, SqlBulkCopyOptions.TableLock, null))
		{
			bulkCopy.DestinationTableName = tableName;
			bulkCopy.BulkCopyTimeout = 1200;
			bulkCopy.BatchSize = batch.Count;

			bulkCopy.ColumnMappings.Add(0, "Date");
			bulkCopy.ColumnMappings.Add(1, "Ticker");
			bulkCopy.ColumnMappings.Add(2, "AskExchange");
			bulkCopy.ColumnMappings.Add(3, "AskPrice");
			bulkCopy.ColumnMappings.Add(4, "AskSize");
			bulkCopy.ColumnMappings.Add(5, "BidExchange");
			bulkCopy.ColumnMappings.Add(6, "BidPrice");
			bulkCopy.ColumnMappings.Add(7, "BidSize");
			bulkCopy.ColumnMappings.Add(8, "Conditions");
			bulkCopy.ColumnMappings.Add(9, "Indicators");
			bulkCopy.ColumnMappings.Add(10, "ParticipantTimestamp");
			bulkCopy.ColumnMappings.Add(11, "SequenceNumber");
			bulkCopy.ColumnMappings.Add(12, "SipTimestamp");
			bulkCopy.ColumnMappings.Add(13, "Tape");
			bulkCopy.ColumnMappings.Add(14, "TrfTimestamp");

			using (var dataReader = new ObjectArrayReader(batch, 15))
			{
				bulkCopy.WriteToServer(dataReader);
			}
		}
	}
}

class ObjectArrayReader : IDataReader
{
	private readonly List<object[]> _data;
	private readonly int _fieldCount;
	private int _currentIndex = -1;

	public ObjectArrayReader(List<object[]> data, int fieldCount)
	{
		_data = data;
		_fieldCount = fieldCount;
	}

	public bool Read()
	{
		_currentIndex++;
		return _currentIndex < _data.Count;
	}

	public int FieldCount => _fieldCount;
	public object GetValue(int i) => _data[_currentIndex][i];
	public int GetValues(object[] values)
	{
		var row = _data[_currentIndex];
		var count = Math.Min(values.Length, _fieldCount);
		Array.Copy(row, values, count);
		return count;
	}

	public bool IsDBNull(int i) => _data[_currentIndex][i] == DBNull.Value || _data[_currentIndex][i] == null;
	public string GetName(int i) => i.ToString();
	public int GetOrdinal(string name) => int.Parse(name);
	public string GetDataTypeName(int i) => GetFieldType(i).Name;

	public Type GetFieldType(int i)
	{
		var val = _data[_currentIndex][i];
		if (val == null || val == DBNull.Value) return typeof(object);
		return val.GetType();
	}

	// Required IDataReader members
	public void Close() { }
	public void Dispose() { }
	public int Depth => 0;
	public bool IsClosed => false;
	public int RecordsAffected => -1;
	public DataTable GetSchemaTable() => null;
	public bool NextResult() => false;

	// Typed accessors - not used by SqlBulkCopy but required by interface
	public bool GetBoolean(int i) => (bool)GetValue(i);
	public byte GetByte(int i) => (byte)GetValue(i);
	public long GetBytes(int i, long fieldOffset, byte[] buffer, int bufferoffset, int length) => 0;
	public char GetChar(int i) => (char)GetValue(i);
	public long GetChars(int i, long fieldoffset, char[] buffer, int bufferoffset, int length) => 0;
	public IDataReader GetData(int i) => null;
	public System.DateTime GetDateTime(int i) => (System.DateTime)GetValue(i);
	public decimal GetDecimal(int i) => (decimal)GetValue(i);
	public double GetDouble(int i) => (double)GetValue(i);
	public float GetFloat(int i) => (float)GetValue(i);
	public Guid GetGuid(int i) => (Guid)GetValue(i);
	public short GetInt16(int i) => (short)GetValue(i);
	public int GetInt32(int i) => (int)GetValue(i);
	public long GetInt64(int i) => (long)GetValue(i);
	public string GetString(int i) => (string)GetValue(i);
	public object this[int i] => GetValue(i);
	public object this[string name] => GetValue(GetOrdinal(name));
}
