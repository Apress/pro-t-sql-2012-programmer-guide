using System;
using System.Linq;

namespace Apress.Examples
{
    class Listing15_12
    {
        static void Main(string[] args)
        {
            AdventureWorksDataContext db = new AdventureWorksDataContext();
            db.Log = Console.Out;

            var query = from p in db.Persons
                        select p;

            foreach (Person p in query)
            {
                Console.WriteLine
                  (
                    "{0}\t{1}\t{2}",
                    p.FirstName,
                    p.MiddleName,
                    p.LastName
                  );
            }
            Console.WriteLine("Press a key to continue...");
            Console.ReadKey();
        }
    }
}
