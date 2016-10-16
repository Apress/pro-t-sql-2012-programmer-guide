using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

namespace Apress.Examples {
    [Serializable]
    [Microsoft.SqlServer.Server.SqlUserDefinedAggregate(Format.Native)]

    public struct Range
    {
        SqlDouble min, max;
        
        public void Init() {
            min = SqlDouble.Null;
            max = SqlDouble.Null; 
        }

        public void Accumulate(SqlDouble value) 
        { 
            if (!value.IsNull) { 
                if (min.IsNull || value < min) 
                {
                    min = value; 
                }

                if (max.IsNull || value > max) 
                {
                    max = value; 
                } 
            } 
        }

        public void Merge(Range group) 
        {
            if (min.IsNull || (!group.min.IsNull && group.min < min)) 
            { 
                min = group.min;
            }
            if (max.IsNull || (!group.max.IsNull && group.max > max))
            { 
                max = group.max;
            } 
        }

        public SqlDouble Terminate() { 
            SqlDouble result = SqlDouble.Null; 
            if (!min.IsNull && !max.IsNull) 
            {
                result = max - min; 
            }

            return result; 
        } 
    } 
}