using System;
using System.Linq;
using System.Text;

namespace EntityFramework
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var ctx = new AdventureWorksEntitiesEmployee())
            {
                foreach (var emp in ctx.Employee.Where(e => e.Gender == "F").Take(5))
                {
                    Console.WriteLine("{0} {1}, born {2}", 
                                      emp.Person.FirstName, 
                                      emp.Person.LastName, 
                                      emp.BirthDate.ToLongDateString()
                    );
                }
                Console.Read();
            }
        }
    }
} 
