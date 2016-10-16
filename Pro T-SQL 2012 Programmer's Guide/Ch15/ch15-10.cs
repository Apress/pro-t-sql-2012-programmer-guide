using System;
using System.Data;
using System.Data.SqlClient;

namespace Apress.Examples
{
    class MARS
    {
        static string sqlconnection = @"SERVER=SQL2012; " +
          "INITIAL CATALOG=AdventureWorks; " +
          "INTEGRATED SECURITY=SSPI; " +
          "MULTIPLEACTIVERESULTSETS=true; ";

        static string sqlcommand1 = "SELECT " +
          "  DepartmentID, " +
          "  Name, " +
          "  GroupName " +
          "FROM HumanResources.Department; ";

        static string sqlcommand2 = "SELECT " +
          "  ShiftID, " +
          "  Name, " +
          "  StartTime, " +
          "  EndTime " +
          "FROM HumanResources.Shift; ";

        static SqlConnection connection = null;
        static SqlCommand command1 = null;
        static SqlCommand command2 = null;
        static SqlDataReader datareader1 = null;
        static SqlDataReader datareader2 = null;

        static void Main(string[] args)
        {
            try
            {
                connection = new SqlConnection(sqlconnection);
                connection.Open();
                command1 = new SqlCommand(sqlcommand1, connection);
                command2 = new SqlCommand(sqlcommand2, connection);
                datareader1 = command1.ExecuteReader();
                datareader2 = command2.ExecuteReader();
                int i = 0;

                Console.WriteLine("===========");
                Console.WriteLine("Departments");
                Console.WriteLine("===========");
                while (datareader1.Read() && i++ < 3)
                {
                    Console.WriteLine
                    (
                      "{0}\t{1}\t{2}",
                      datareader1["DepartmentID"].ToString(),
                      datareader1["Name"].ToString(),
                      datareader1["GroupName"].ToString()
                    );
                }

                Console.WriteLine("======");
                Console.WriteLine("Shifts");
                Console.WriteLine("======");
                while (datareader2.Read())
                {
                    Console.WriteLine
                    (
                      "{0}\t{1}\t{2}\t{3}",
                      datareader2["ShiftID"].ToString(),
                      datareader2["Name"].ToString(),
                      datareader2["StartTime"].ToString(),
                      datareader2["EndTime"].ToString()
                    );
                }

                Console.WriteLine("======================");
                Console.WriteLine("Departments, Continued");
                Console.WriteLine("======================");
                while (datareader1.Read())
                {
                    Console.WriteLine
                    (
                      "{0}\t{1}\t{2}",
                      datareader1["DepartmentID"].ToString(),
                      datareader1["Name"].ToString(),
                      datareader1["GroupName"].ToString()
                    );
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                if (datareader1 != null)
                    datareader1.Dispose();
                if (datareader2 != null)
                    datareader2.Dispose();
                if (command1 != null)
                    command1.Dispose();
                if (command2 != null)
                    command2.Dispose();
                if (connection != null)
                    connection.Dispose();
            }
            Console.WriteLine("Press a key to end...");
            Console.ReadKey();
        }
    }
}
