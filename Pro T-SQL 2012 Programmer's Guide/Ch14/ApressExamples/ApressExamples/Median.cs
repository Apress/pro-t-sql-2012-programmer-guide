using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlTypes;
using System.Runtime.InteropServices;
using Microsoft.SqlServer.Server;

namespace Apress.Examples {
    [Serializable]
    [Microsoft.SqlServer.Server.SqlUserDefinedAggregate ( 
        Format.UserDefined, 
        IsNullIfEmpty = true, 
        MaxByteSize = -1 )] 
    [StructLayout(LayoutKind.Sequential)] 
    
    public struct Median : IBinarySerialize 
    {
        List<double> temp; // List of numbers

        public void Init() 
        {
            // Create new list of double numbers
            this.temp = new List<double>(); 
        }

        public void Accumulate(SqlDouble number) 
        {
            if (!number.IsNull) // Skip over NULLs
            { 
                this.temp.Add(number.Value); // If number is not NULL, add it to list
            } 
        }

        public void Merge(Median group) 
        {
            // Merge two sets of numbers
            this.temp.InsertRange(this.temp.Count, group.temp); 
        }

        public SqlDouble Terminate() {
            SqlDouble result = SqlDouble.Null; // Default result to NULL
            this.temp.Sort(); // Sort list of numbers

            int first, second; // Indexes to middle two numbers

            if (this.temp.Count % 2 == 1) 
            {
                // If there is an odd number of values get the middle number twice
                first = this.temp.Count / 2;
                second = first; 
            }
            else 
            {
                // If there is an even number of values get the middle two numbers
                first = this.temp.Count / 2 - 1;
                second = first + 1; 
            }
            
            if (this.temp.Count > 0) // If there are numbers, calculate median
            { 
                // Calculate median as average of middle number(s) 
                result = (SqlDouble)( this.temp[first] + this.temp[second] ) / 2.0;
            }

            return result; 
        }

        #region IBinarySerialize Members
        
        // Custom serialization read method 
        public void Read(System.IO.BinaryReader r) 
        {
            // Create a new list of double values 
            this.temp = new List<double>();        
            
            // Get the number of values that were serialized 
            int j = r.ReadInt32();
        
            // Loop and add each serialized value to the list
            for (int i = 0; i < j; i++)
            {
                this.temp.Add(r.ReadDouble()); 
            } 
        }
        
        // Custom serialization write method 
        public void Write(System.IO.BinaryWriter w) 
        {
            // Write the number of values in the list
            w.Write(this.temp.Count);

            // Write out each value in the list 
            foreach (double d in this.temp) 
            {
                w.Write(d); 
            } 
        }
        
        #endregion 
    } 
}
