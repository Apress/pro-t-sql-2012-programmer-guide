using System;
using System.Collections;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Xml;

namespace Apress.Examples
{
    public partial class YahooRSS
    {

        [Microsoft.SqlServer.Server.SqlFunction(
            IsDeterministic = false,
            DataAccess = DataAccessKind.None,
            TableDefinition = "title nvarchar(256),"
            + "link nvarchar(256), "
            + "pubdate datetime, "
            + "description nvarchar(max)",
            FillRowMethodName = "GetRow")
        ]
        public static IEnumerable GetYahooNews()
        {
            XmlTextReader xmlsource =
                new XmlTextReader("http://rss.news.yahoo.com/rss/topstories");
            XmlDocument newsxml = new XmlDocument();
            newsxml.Load(xmlsource);
            xmlsource.Close();
            return newsxml.SelectNodes("//rss/channel/item");
        }
        private static void GetRow(
            Object o,
            out SqlString title,
            out SqlString link,
            out SqlDateTime pubdate,
            out SqlString description)
        {
            XmlElement element = (XmlElement)o;
            title = element.SelectSingleNode("./title").InnerText;
            link = element.SelectSingleNode("./link").InnerText;
            pubdate = DateTime.Parse(element.SelectSingleNode("./pubDate").InnerText);
            description = element.SelectSingleNode("./description").InnerText;
        }
    }
}
