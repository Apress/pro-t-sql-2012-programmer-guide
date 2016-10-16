using System;
using System.Data;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;
using System.Transactions; // you need to add the reference. Right-click on Project and add reference, SQL Server tab, System.Transactions for framework 4.0.0.0

namespace Apress.Examples
{
    public partial class Triggers
    {
        private static readonly Regex email_pattern = new Regex
        (
            //  Everything  before  the  @  sign  (the  "local  part")
            "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*" +

            //  Subdomains  after  the  @  sign
            "@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+" +

            // Top-level domains
            "(?:[a-z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)\\b$"
        );

        // Enter existing table or view for the target and uncomment the attribute line
        [Microsoft.SqlServer.Server.SqlTrigger(Name = "EmailAddressTrigger", Target = "[Person].[EmailAddress]", Event = "FOR INSERT, UPDATE")]
        public static void EmailAddressTrigger()
        {
            SqlTriggerContext tContext = SqlContext.TriggerContext;

            // Retrieve the connection that the trigger is using.
            using (SqlConnection cn
               = new SqlConnection(@"context connection=true"))
            {
                SqlCommand cmd;
                SqlDataReader r;

                cn.Open();

                cmd = new SqlCommand(@"SELECT EmailAddress FROM INSERTED", cn);
                r = cmd.ExecuteReader();
                try
                {
                    while (r.Read())
                    {
                        if (!email_pattern.IsMatch(r.GetString(0).ToLower()))
                        {
                            Transaction.Current.Rollback();
                        }
                    }
                }
                catch (SqlException ex)
                {
                    // Catch the expected exception.
                }
                finally
                {
                    r.Close();
                    cn.Close();
                }
            }
        }
    }
}