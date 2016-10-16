Listing 15-3. Parameterized SQL Query
using System;
using System.Data;
using System.Data.SqlClient;

namespace Apress.Examples
{
    class Listing15_3
    {
        static void Main(string[] args)
        {

            string name = "SMITH";
            string sqlconnection = @"SERVER=SQL2012; " +
              "INITIAL CATALOG=AdventureWorks; " +
              "INTEGRATED SECURITY=SSPI;";

            string sqlcommand = "SELECT " +
              "  BusinessEntityID, " +
              "  FirstName, " +
              "  MiddleName, " +
              "  LastName " +
              "FROM Person.Person " +
              "WHERE LastName = @name";

            SqlConnection connection = null;
            SqlCommand command = null;
            SqlDataReader datareader = null;

            try
            {
                connection = new SqlConnection(sqlconnection);
                connection.Open();
                command = new SqlCommand(sqlcommand, connection);
                command.Parameters.Add("@name", SqlDbType.NVarChar, 50).Value = name;
                datareader = command.ExecuteReader();
                while (datareader.Read())
                {
                    Console.WriteLine
                      (
                        "{0}\t{1}\t{2}\t{3}",
                        datareader["BusinessEntityID"].ToString(),
                        datareader["LastName"].ToString(),
                        datareader["FirstName"].ToString(),
                        datareader["MiddleName"].ToString()
                      );
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                connection.Close();
            }
            Console.WriteLine("Press any key...");
            Console.ReadKey();
        }
    }
}
