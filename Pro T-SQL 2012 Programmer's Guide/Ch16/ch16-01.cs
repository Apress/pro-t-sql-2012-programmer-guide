using System;
using System.Data.SqlClient;
using System.Text;

namespace localdbClient
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                SqlConnectionStringBuilder builder =
                    new SqlConnectionStringBuilder(@"Server=(localdb)\SQLSrvWebApp1;Integrated Security=true");

                builder.AttachDBFilename = @"C:\Users\Administrator\Documents\AdventureWorksLT2012_Data.mdf";

                Console.WriteLine("connection string = " + builder.ConnectionString);

                using (SqlConnection cn = new SqlConnection(builder.ConnectionString))
                {
                    cn.Open();
                    SqlCommand cmd = cn.CreateCommand();
                    cmd.CommandText = "SELECT Name FROM sys.tables;";
                    SqlDataReader rd = cmd.ExecuteReader();
                    
                    while(rd.Read()) 
                    {
                        Console.WriteLine(rd.GetValue(0));
                    }
                    rd.Close();
                    cn.Close();
                }
                Console.WriteLine("Press any key to finish.");
                Console.ReadLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.WriteLine("Press any key to finish.");
                Console.ReadLine();
            }
        }
    }
}
