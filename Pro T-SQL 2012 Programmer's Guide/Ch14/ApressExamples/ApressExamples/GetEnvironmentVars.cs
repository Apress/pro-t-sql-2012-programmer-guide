using System;
using System.Collections;
using System.Data;

using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
namespace Apress.Examples
{
    public partial class SampleProc
    {
        [Microsoft.SqlServer.Server.SqlProcedure()]
        public static void GetEnvironmentVars() 
        { 
            try 
            { 
                SortedList environment_list = new SortedList();
                foreach (DictionaryEntry de in Environment.GetEnvironmentVariables()) 
                {
                    environment_list[de.Key] = de.Value; 
                }

                SqlDataRecord record = new SqlDataRecord ( 
                    new SqlMetaData("VarName", SqlDbType.NVarChar, 1024),
                    new SqlMetaData("VarValue", SqlDbType.NVarChar, 4000) 
                ); 
                SqlContext.Pipe.SendResultsStart(record); 
                foreach (DictionaryEntry de in environment_list) 
                { 
                    record.SetValue(0, de.Key); 
                    record.SetValue(1, de.Value); 
                    SqlContext.Pipe.SendResultsRow(record); 
                }

                SqlContext.Pipe.SendResultsEnd(); 
            }
            catch (Exception ex) 
            {
                SqlContext.Pipe.Send(ex.Message); 
            } 
        }
    }
};
