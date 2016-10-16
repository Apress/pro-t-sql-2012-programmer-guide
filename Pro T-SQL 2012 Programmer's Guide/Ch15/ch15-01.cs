Listing 15-1. SqlDataReader Sample
using System;
using System.Data.SqlClient;

namespace Apress.Examples
{
    class Listing15_1
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

            try
            {
                connection = new SqlConnection(sqlconnection);
                connection.Open();
                command = new SqlCommand(sqlcommand, connection);
                datareader = command.ExecuteReader();

                while (datareader.Read())
                {
                    Console.WriteLine
                      (
                        "{0}\t{1}\t{2}",
                        datareader["DepartmentId"].ToString(),
                        datareader["Name"].ToString(),
                        datareader["GroupName"].ToString()
                      );
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                connection.Close();
            }
            Console.Write("Press a Key to Continue...");
            Console.ReadKey();
        }
    }
}
