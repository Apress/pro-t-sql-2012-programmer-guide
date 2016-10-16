using System;
using System.Collections.Generic;
using System.Data.Services;
using System.Data.Services.Common;
using System.Linq;
using System.ServiceModel.Web;
using System.Web;

namespace WCFDataServicesSample
{
    public class ProductPhotoDataService : DataService<AdventureWorksEntities>
    {
        // This method is called only once to initialize service-wide policies.
        public static void InitializeService(DataServiceConfiguration config)
        {
            config.SetEntitySetAccessRule("Products", EntitySetRights.AllRead); 
            config.SetEntitySetAccessRule("ProductPhotoes", EntitySetRights.AllRead); 
            config.SetEntitySetAccessRule("ProductProductPhotoes", EntitySetRights.AllRead);
            config.DataServiceBehavior.MaxProtocolVersion = DataServiceProtocolVersion.V2;
        }
    }
}
