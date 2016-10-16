private async Task ExecuteSP()
{
    SqlConnectionStringBuilder cnString = new SqlConnectionStringBuilder();
    cnString.DataSource = @�(localdb)\v11.0�;
    cnString.IntegratedSecurity = true;

    using (SqlConnection cn = new SqlConnection(cnString.ConnectionString))
    {
        await cn.OpenAsync();
        SqlCommand cmd = new SqlCommand("EXEC dbo.GetProducts", cn);
        await cmd.ExecuteReaderAsync();
    }
}
