using System.Data.SqlTypes;
using System.Text.RegularExpressions;

namespace Apress.Examples
{
    public static class UDFExample
    {
        private static readonly Regex email_pattern = new Regex
        (
            //  Everything  before  the  @  sign  (the  "local  part")
        "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*" +

        //  Subdomains  after  the  @  sign
        "@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+" +

        // Top-level domains
        "(?:[a-z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)\\b$"
        );

        [Microsoft.SqlServer.Server.SqlFunction
        (
        IsDeterministic = true
        )]
        public static SqlBoolean EmailMatch(SqlString input)
        {
            SqlBoolean result = new SqlBoolean();
            if (input.IsNull)
                result = SqlBoolean.Null;
            else
                result = (email_pattern.IsMatch(input.Value.ToLower()) == true)
                ? SqlBoolean.True : SqlBoolean.False;
            return result;
        }
    }
}
