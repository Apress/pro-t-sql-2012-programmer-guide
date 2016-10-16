using System;
using System.Linq;

namespace Apress.Examples
{
    class Listing15_18
    {
        static void Main(string[] args)
        {
            AdventureWorksDataContext db = new AdventureWorksDataContext();
            db.Log = Console.Out;

            var query = from p in db.Persons
                        join e in db.EmailAddresses
                        on p.BusinessEntityID equals e.BusinessEntityID
                        where p.LastName.Contains("SMI")
                        orderby p.LastName, p.FirstName
                        select new
                        {
                            LastName = p.LastName,
                            FirstName = p.FirstName,
                            MiddleName = p.MiddleName,
                            EmailAddress = e.EmailAddress1
                        };

            foreach (var q in query)
            {
                Console.WriteLine
                  (
                    "{0}\t{1}\t{2}\t{3}",
                    q.FirstName,
                    q.MiddleName,
                    q.LastName,
                    q.EmailAddress
                  );
            }
            Console.WriteLine("Press a key to continue...");
            Console.ReadKey();
        }
    }
}
