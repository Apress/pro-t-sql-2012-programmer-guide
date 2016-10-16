using System;
using System.Data;
using System.Data.SqlClient;
using System.Xml;

namespace Apress.Examples
{
    class Listing15_6
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
              "  COALESCE(MiddleName, '') AS MiddleName, " +
              "  LastName " +
              "FROM Person.Person " +
              "WHERE LastName = @name " +
              "FOR XML AUTO;";

            SqlConnection connection = null;
            SqlCommand command = null;
            XmlReader xmlreader = null;

            try
            {
                connection = new SqlConnection(sqlconnection);
                connection.Open();
                command = new SqlCommand(sqlcommand, connection);
                SqlParameter par = command.Parameters.Add("@name", SqlDbType.NVarChar,
                  50);
                par.Value = name;
                xmlreader = command.ExecuteXmlReader();
                while (xmlreader.Read())
                {
                    Console.WriteLine
                    (
                      "{0}\t{1}\t{2}\t{3}",
                      xmlreader["BusinessEntityID"].ToString(),
                      xmlreader["LastName"].ToString(),
                      xmlreader["FirstName"].ToString(),
                      xmlreader["MiddleName"].ToString()
                    );
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                if (xmlreader != null)
                    xmlreader.Close();
                if (command != null)
                    command.Dispose();
                if (connection != null)
                    connection.Dispose();
            }
            Console.WriteLine("Press any key...");
            Console.ReadKey();
        }
    }
}
