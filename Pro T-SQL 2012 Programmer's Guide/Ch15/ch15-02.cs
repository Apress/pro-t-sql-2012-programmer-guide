Listing 15-2. Using SqlDataReader to Fill a DataSet
using System;
using System.Data;
using System.Data.SqlClient;

namespace Apress.Examples
{
    class Listing15_2
    {
        static void Main(string[] args)
        {
            string sqlconnection = @"DATA SOURCE=SQL2012;" +
              "INITIAL CATALOG=AdventureWorks;" +
              "INTEGRATED SECURITY=SSPI;";

            string sqlcommand = "SELECT " +
              "   DepartmentId, " +
              "   Name, " +
              "   GroupName " +
              " FROM HumanResources.Department " +
              " ORDER BY DepartmentId";

            SqlDataAdapter adapter = null;
            DataSet dataset = null;

            try
            {
                adapter = new SqlDataAdapter(sqlcommand, sqlconnection);
                dataset = new DataSet();
                adapter.Fill(dataset);

                foreach (DataRow row in dataset.Tables[0].Rows)
                {
                    Console.WriteLine
                      (
                        "{0}\t{1}\t{2}",
                        row["DepartmentId"].ToString(),
                        row["Name"].ToString(),
                        row["GroupName"].ToString()
                      );
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                if (dataset != null)
                    dataset.Dispose();
                if (adapter != null)
                    adapter.Dispose();
            }
            Console.Write("Press a Key to Continue...");
            Console.ReadKey();
        }
    }
}
