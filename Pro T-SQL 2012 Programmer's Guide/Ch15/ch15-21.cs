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
                var qry = from e in ctx.Employee
                          where e.Gender == "F"
                          select new
                          {
                              e.Person.FirstName,
                              e.Person.LastName,
                              e.BirthDate
                          };

                foreach (var emp in qry.Take(5)) {
                    Console.WriteLine("{0} {1}, born {2}", 
                                      emp.FirstName, 
                                      emp.LastName, 
                                      emp.BirthDate.ToLongDateString()
                    );
                }
                Console.Read();
            }
        }
    }
}
