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
                var newP = new BusinessEntity {
                    ModifiedDate = DateTime.Now,
                    rowguid = Guid.NewGuid()
                };

                Console.WriteLine("BusinessEntityID before insert : {0}", 
                                  newP.BusinessEntityID);

                ctx.BusinessEntities.AddObject(newP);
                ctx.SaveChanges();

                Console.WriteLine("BusinessEntityID after insert :  {0}", 
                                  newP.BusinessEntityID);
            }

            Console.Read();
        }
    }
}
