using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

[Serializable]
[SqlUserDefinedAggregate(Format.Native)]
public struct Correlation
{
    private double sumX;
    private double sumY;
    private double sumXY;
    private double sumXSquare;
    private double sumYSquare;
    private int count;

    // This method is called once per row to accumulate the aggregate data
    public void Init()
    {
        sumX = 0;
        sumY = 0;
        sumXY = 0;
        sumXSquare = 0;
        sumYSquare = 0;
        count = 0;
    }

    // Accumulate the values of x and y
    public void Accumulate(SqlDouble x, SqlDouble y)
    {
        if (x.IsNull || y.IsNull)
        {
            return;
        }

        double xVal = x.Value;
        double yVal = y.Value;

        sumX += xVal;
        sumY += yVal;
        sumXY += xVal * yVal;
        sumXSquare += xVal * xVal;
        sumYSquare += yVal * yVal;
        count++;
    }

    // Merge intermediate results from other instances (used in parallel executions)
    public void Merge(Correlation group)
    {
        sumX += group.sumX;
        sumY += group.sumY;
        sumXY += group.sumXY;
        sumXSquare += group.sumXSquare;
        sumYSquare += group.sumYSquare;
        count += group.count;
    }

    // Compute the Pearson correlation coefficient based on the accumulated data
    public SqlDouble Terminate()
    {
        if (count == 0)
        {
            return SqlDouble.Null;
        }

        double numerator = (count * sumXY) - (sumX * sumY);
        double denominator = Math.Sqrt((count * sumXSquare - sumX * sumX) * (count * sumYSquare - sumY * sumY));

        if (denominator == 0)
        {
            return SqlDouble.Null;
        }

        return new SqlDouble(numerator / denominator);
    }
}
