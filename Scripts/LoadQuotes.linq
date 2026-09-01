<Query Kind="Program">
  <NuGetReference>Cobbler.Extensions</NuGetReference>
</Query>

// ============================================================
// LoadDailyQuotes.linq
// 
// Streams a 60GB+ Massive/Polygon NBBO quote CSV into SQL Server
// using: CSV streaming → SqlBulkCopy → Staging table → Partition SWITCH
//
// Usage: Set the 3 variables below and run.
// ============================================================

// ─── CONFIGURATION ───────────────────────────────────────────
static string ConnectionString = Cobbler.Extensions.Config.Connections.CobblerMarketDataConnectionString;
static string CsvFilePath = @"C:\Users\mvays\Downloads\Data\2026-01-30.csv\2026-01-30.csv";
static string TradeDate = "2026-01-30";  // the session date for this file
										 // ─────────────────────────────────────────────────────────────
static string TargetTable = "[pgon].[ExchangeQuotes]";
static int BatchSize = 500_000;

void Main()
{
	var sw = Stopwatch.StartNew();
	var allowedTickers = BuildTickerFilter();
	$"Ticker filter loaded: {allowedTickers.Count} tickers".Dump();
	$"Starting load for {TradeDate} from {CsvFilePath}".Dump("Load Daily Quotes");
	$"File size: {new FileInfo(CsvFilePath).Length / (1024.0 * 1024 * 1024):F2} GB".Dump();

	using var conn = new SqlConnection(ConnectionString);
	conn.Open();

	// Bulk load CSV → target table directly
	"Bulk loading (filtered to ~543 tickers + market hours)...".Dump();

	using var bulkCopy = new SqlBulkCopy(conn, SqlBulkCopyOptions.TableLock, null)
	{
		DestinationTableName = TargetTable,
		BatchSize = BatchSize,
		BulkCopyTimeout = 0,
		EnableStreaming = true,
		NotifyAfter = 1_000_000
	};

	bulkCopy.ColumnMappings.Add("date", "date");
	bulkCopy.ColumnMappings.Add("ticker", "ticker");
	bulkCopy.ColumnMappings.Add("sip_timestamp", "sip_timestamp");
	bulkCopy.ColumnMappings.Add("participant_timestamp", "participant_timestamp");
	bulkCopy.ColumnMappings.Add("sequence_number", "sequence_number");
	bulkCopy.ColumnMappings.Add("ask_exchange", "ask_exchange");
	bulkCopy.ColumnMappings.Add("ask_price", "ask_price");
	bulkCopy.ColumnMappings.Add("ask_size", "ask_size");
	bulkCopy.ColumnMappings.Add("bid_exchange", "bid_exchange");
	bulkCopy.ColumnMappings.Add("bid_price", "bid_price");
	bulkCopy.ColumnMappings.Add("bid_size", "bid_size");
	bulkCopy.ColumnMappings.Add("conditions", "conditions");
	bulkCopy.ColumnMappings.Add("indicators", "indicators");
	bulkCopy.ColumnMappings.Add("tape", "tape");

	using var reader = new FilteredQuoteCsvDataReader(CsvFilePath, TradeDate, allowedTickers);

	bulkCopy.SqlRowsCopied += (sender, e) =>
	{
		$"  → {e.RowsCopied:N0} rows loaded (skipped {reader.SkippedCount:N0}) [{sw.Elapsed}]".Dump();
	};

	bulkCopy.WriteToServer(reader);

	sw.Stop();
	$"✓ Done! {reader.LoadedCount:N0} rows loaded, {reader.SkippedCount:N0} skipped in {sw.Elapsed}".Dump("Complete");
	$"Filter efficiency: kept {(reader.LoadedCount * 100.0 / (reader.LoadedCount + reader.SkippedCount)):F1}% of rows".Dump();
}

// ─── TICKER FILTER ───────────────────────────────────────────

static HashSet<string> BuildTickerFilter()
{
	var tickers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

	var sp500 = new[] {
		"NVDA","AAPL","MSFT","AMZN","GOOGL","GOOG","META","AVGO","TSLA","BRK.B",
		"WMT","LLY","JPM","V","XOM","JNJ","MU","MA","COST","ORCL",
		"ABBV","BAC","HD","PG","CVX","GE","CAT","KO","NFLX","AMD",
		"PLTR","CSCO","LRCX","MRK","AMAT","PM","MS","GS","RTX","WFC",
		"UNH","IBM","AXP","TMUS","MCD","LIN","PEP","GEV","INTC","VZ",
		"C","AMGN","TXN","KLAC","T","ABT","NEE","TMO","GILD","DIS",
		"APH","BA","DE","ISRG","TJX","CRM","ADI","BLK","ANET","SCHW",
		"UNP","LOW","HON","QCOM","UBER","PFE","LMT","DHR","SYK","WELL",
		"ETN","APP","COP","NEM","ACN","PLD","BKNG","COF","CB","PH",
		"SPGI","MDT","BMY","VRTX","PANW","GLW","PGR","HCA","MCK","MO",
		"CMCSA","SBUX","CME","BSX","NOW","CEG","ADBE","INTU","SO","HWM",
		"TT","NOC","UPS","DUK","CRWD","CVS","NKE","WDC","SNDK","GD",
		"BX","PNC","WM","FCX","MAR","FDX","USB","EQIX","KKR","STX",
		"SHW","WMB","JCI","MMM","AMT","ICE","MRSH","ADP","ECL","RCL",
		"ITW","SNPS","EMR","CRH","REGN","PWR","CMI","MNST","BK","DELL",
		"CDNS","CTAS","MCO","ORLY","CSX","ABNB","MSI","CL","SLB","DASH",
		"ELV","TDG","MDLZ","CI","GM","KMI","HLT","WBD","NSC","COR",
		"AEP","AON","APO","TEL","HOOD","RSG","PCAR","EOG","LHX","TFC",
		"TRV","SPG","ROST","PSX","APD","AZO","BKR","VLO","SRE","O",
		"DLR","FTNT","AFL","MPWR","NXPI","VST","MPC","URI","D","F",
		"AJG","OKE","ZTS","AME","ALL","CARR","GWW","PSA","FAST","TGT",
		"CAH","BDX","MET","FIX","CTVA","OXY","TER","IDXX","EA","FANG",
		"TRGP","CMG","EXC","FITB","XEL","ADSK","GRMN","CVNA","DHI","CIEN",
		"ETR","NDAQ","EW","DAL","COIN","YUM","WAB","HSY","ROK","CCL",
		"CBRE","SYY","AIG","AMP","PEG","ODFL","MCHP","KR","KEYS","MLM",
		"EL","NUE","VTR","DDOG","PCG","VMC","KDP","MSCI","EBAY","ED",
		"HIG","LVS","NRG","GEHC","PYPL","CCI","LYV","EQT","RMD","IR",
		"WEC","TTWO","UAL","HBAN","EME","WDAY","KMB","OTIS","PRU","KVUE",
		"ROP","MTB","STT","ACGL","CPRT","A","AXON","TPL","DG","IBKR",
		"FISV","PAYX","WAT","IRM","ADM","EXR","XYZ","VICI","FICO","TPR",
		"DOV","TDY","XYL","RJF","CTSH","AEE","ULTA","CBOE","DTE","ATO",
		"ROL","HAL","CHTR","FE","KHC","LEN","WTW","JBL","HPE","PPG",
		"EIX","STLD","BIIB","DXCM","IQV","CNP","HUBB","MTD","TSCO","CFG",
		"PPL","ES","DVN","ON","ARES","STZ","NTRS","PHM","WRB","DLTR",
		"OMC","RF","FSLR","EXE","WSM","LUV","SYF","SW","FIS","VRSK",
		"CINF","AWK","AVB","DRI","EXPE","IP","CPAY","STE","KEY","CHD",
		"EQR","GIS","EFX","Q","CTRA","BRO","BG","LH","AMCR","RL",
		"CMS","VLTO","GPN","HUM","L","CHRW","TSN","DGX","LDOS","LULU",
		"NI","DOW","JBHT","PKG","SBAC","CNC","NVR","CSGP","EXPD","IFF",
		"PFG","TROW","BR","DD","NTAP","INCY","SNA","ALB","VRSN","ZBH",
		"LII","MRNA","SMCI","EVRG","PTC","MKC","VTRS","FTV","LNT","LYB",
		"WY","BALL","TXT","WST","HII","HPQ","PODD","APTV","DECK","HOLX",
		"PNR","TKO","COO","GPC","ESS","CDW","J","NDSN","TRMB","FFIV",
		"KIM","MAA","IEX","INVH","MAS","AVY","CF","CLX","BEN","UHS",
		"ERIE","SWK","HAS","REG","HST","ALLE","EG","BF.B","HRL","TYL",
		"ALGN","AKAM","GEN","BBY","GNRC","DPZ","SOLV","ZBRA","GDDY","BLDR",
		"UDR","TTD","WYNN","PSKY","DOC","SJM","PNW","AES","IVZ","FOX",
		"GL","JKHY","FOXA","RVTY","AIZ","BAX","CPT","NCLH","IT","AOS",
		"APA","DVA","TAP","BXP","MGM","HSIC","MOS","ARE","FRT","SWKS",
		"TECH","CAG","NWSA","CRL","POOL","CPB","MOH","EPAM","MTCH","FDS",
		"LW","PAYC","NWS"
	};

	var etfs = new[] {
		"SPY","QQQ","IWM","DIA","VOO","VTI",
		"XLF","XLK","XLE","XLV","XLI","XLU",
		"VXX","EFA","EEM","GLD","USO",
		"TLT","HYG","LQD"
	};

	var bondEtfs = new[] {
		"TLT","IEF","SHY","SHV","TIP","GOVT","VGSH",
		"LQD","VCIT","VCSH",
		"HYG","JNK","USHY",
		"AGG","BND","BNDX",
		"MUB","VTEB",
		"TMF","TBT"
	};

	foreach (var t in sp500) tickers.Add(t);
	foreach (var t in etfs) tickers.Add(t);
	foreach (var t in bondEtfs) tickers.Add(t);

	return tickers;
}

// ============================================================
// Streaming IDataReader — filters by ticker + market hours.
// Non-matching rows never leave the CSV reader.
// ============================================================
class FilteredQuoteCsvDataReader : IDataReader
{
	private readonly StreamReader _streamReader;
	private readonly CsvReader _csv;
	private readonly string _tradeDate;
	private readonly HashSet<string> _allowedTickers;
	private readonly long _marketOpenNanos;
	private readonly long _marketCloseNanos;
	private Dictionary<string, int> _headerMap;
	private int _tickerColumnIndex;
	private int _sipTimestampColumnIndex;
	private bool _disposed;

	public long LoadedCount { get; private set; }
	public long SkippedCount { get; private set; }

	private static readonly string[] Columns = new[]
	{
		"date", "ticker", "sip_timestamp", "participant_timestamp",
		"sequence_number", "ask_exchange", "ask_price", "ask_size",
		"bid_exchange", "bid_price", "bid_size",
		"conditions", "indicators", "tape"
	};

	public FilteredQuoteCsvDataReader(string filePath, string tradeDate, HashSet<string> allowedTickers)
	{
		_tradeDate = tradeDate;
		_allowedTickers = allowedTickers;

		// Precompute market hours as nanosecond unix timestamps
		var tz = TimeZoneInfo.FindSystemTimeZoneById("Eastern Standard Time");
		var d = DateTime.Parse(tradeDate);
		var openUtc = TimeZoneInfo.ConvertTimeToUtc(new DateTime(d.Year, d.Month, d.Day, 9, 30, 0), tz);
		var closeUtc = TimeZoneInfo.ConvertTimeToUtc(new DateTime(d.Year, d.Month, d.Day, 16, 0, 0), tz);
		_marketOpenNanos = ((DateTimeOffset)openUtc).ToUnixTimeSeconds() * 1_000_000_000L;
		_marketCloseNanos = ((DateTimeOffset)closeUtc).ToUnixTimeSeconds() * 1_000_000_000L;

		_streamReader = new StreamReader(filePath, System.Text.Encoding.UTF8, true, 4 * 1024 * 1024);
		_csv = new CsvReader(_streamReader, new CsvConfiguration(CultureInfo.InvariantCulture)
		{
			HasHeaderRecord = true,
			BadDataFound = null,
			MissingFieldFound = null,
			BufferSize = 4 * 1024 * 1024
		});

		_csv.Read();
		_csv.ReadHeader();
		_headerMap = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
		for (int i = 0; i < _csv.HeaderRecord.Length; i++)
			_headerMap[_csv.HeaderRecord[i].Trim()] = i;

		if (!_headerMap.TryGetValue("ticker", out _tickerColumnIndex))
			throw new Exception("CSV missing 'ticker' column! Headers found: " + string.Join(", ", _csv.HeaderRecord));
		if (!_headerMap.TryGetValue(MapCsvColumnName("sip_timestamp"), out _sipTimestampColumnIndex))
			throw new Exception("CSV missing 'sip_timestamp' column! Headers found: " + string.Join(", ", _csv.HeaderRecord));
	}

	public bool Read()
	{
		while (_csv.Read())
		{
			// Filter 1: Ticker
			string ticker = _csv.GetField(_tickerColumnIndex)?.Trim();
			if (ticker == null || !_allowedTickers.Contains(ticker))
			{
				SkippedCount++;
				continue;
			}

			// Filter 2: Market hours 9:30 AM – 4:00 PM ET
			string sipRaw = _csv.GetField(_sipTimestampColumnIndex)?.Trim();
			if (sipRaw != null && long.TryParse(sipRaw, out long sipNanos))
			{
				if (sipNanos < _marketOpenNanos || sipNanos > _marketCloseNanos)
				{
					SkippedCount++;
					continue;
				}
			}

			LoadedCount++;
			return true;
		}
		return false;
	}

	public int FieldCount => Columns.Length;

	public object GetValue(int i)
	{
		string colName = Columns[i];

		if (colName == "date")
			return _tradeDate;

		if (!_headerMap.TryGetValue(MapCsvColumnName(colName), out int csvIdx))
			return DBNull.Value;

		string raw = _csv.GetField(csvIdx)?.Trim();
		if (string.IsNullOrEmpty(raw)) return DBNull.Value;

		return colName switch
		{
			"ticker" => raw,
			"sip_timestamp" => long.Parse(raw),
			"participant_timestamp" => long.Parse(raw),
			"sequence_number" => long.Parse(raw),
			"ask_exchange" => byte.Parse(raw),
			"ask_price" => decimal.Parse(raw),
			"ask_size" => int.Parse(raw),
			"bid_exchange" => byte.Parse(raw),
			"bid_price" => decimal.Parse(raw),
			"bid_size" => int.Parse(raw),
			"tape" => byte.Parse(raw),
			"conditions" => raw,
			"indicators" => raw,
			_ => raw
		};
	}

	// Adjust if your CSV headers don't match SQL column names
	private static string MapCsvColumnName(string sqlCol) => sqlCol switch
	{
		// "sip_timestamp" => "sip_ts",
		_ => sqlCol
	};

	public string GetName(int i) => Columns[i];
	public int GetOrdinal(string name) => Array.IndexOf(Columns, name);
	public int GetValues(object[] values) { for (int i = 0; i < FieldCount; i++) values[i] = GetValue(i); return FieldCount; }
	public bool IsDBNull(int i) => GetValue(i) == DBNull.Value;
	public object this[int i] => GetValue(i);
	public object this[string name] => GetValue(GetOrdinal(name));
	public int Depth => 0;
	public bool IsClosed => _disposed;
	public int RecordsAffected => -1;
	public void Close() => Dispose();
	public bool NextResult() => false;
	public string GetString(int i) => GetValue(i)?.ToString();
	public int GetInt32(int i) => (int)GetValue(i);
	public long GetInt64(int i) => (long)GetValue(i);
	public decimal GetDecimal(int i) => (decimal)GetValue(i);
	public bool GetBoolean(int i) => (bool)GetValue(i);
	public byte GetByte(int i) => (byte)GetValue(i);
	public char GetChar(int i) => (char)GetValue(i);
	public DateTime GetDateTime(int i) => (DateTime)GetValue(i);
	public double GetDouble(int i) => (double)GetValue(i);
	public float GetFloat(int i) => (float)GetValue(i);
	public Guid GetGuid(int i) => (Guid)GetValue(i);
	public short GetInt16(int i) => (short)GetValue(i);
	public long GetBytes(int i, long o, byte[] b, int bo, int l) => 0;
	public long GetChars(int i, long o, char[] b, int bo, int l) => 0;
	public IDataReader GetData(int i) => null;
	public string GetDataTypeName(int i) => typeof(string).Name;
	public Type GetFieldType(int i) => typeof(object);
	public DataTable GetSchemaTable() => null;

	public void Dispose()
	{
		if (!_disposed)
		{
			_csv?.Dispose();
			_streamReader?.Dispose();
			_disposed = true;
		}
	}
}
