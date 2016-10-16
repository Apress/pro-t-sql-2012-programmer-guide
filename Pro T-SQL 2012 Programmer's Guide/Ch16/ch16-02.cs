private void ExecuteSP()
{
    SqlConnectionStringBuilder cnString = new SqlConnectionStringBuilder();
    cnString.DataSource = @”(localdb)\v11.0”;
    cnString.IntegratedSecurity = true;

    using (SqlConnection cn = new SqlConnection(cnString.ConnectionString))
    {
        cn.Open();
        SqlCommand cmd = new SqlCommand("EXEC dbo.GetProducts", cn);
        cmd.ExecuteReader();
    }
}
