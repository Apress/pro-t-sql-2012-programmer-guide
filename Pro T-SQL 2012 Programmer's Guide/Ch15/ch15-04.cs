SqlCommand command = new SqlCommand
  (
    "CREATE TABLE #temp " +
    "  ( " +
    "    Id INT NOT NULL PRIMARY KEY, " +
    "    Name NVARCHAR(50) " +
    "  );", connection
  );
command.ExecuteNonQuery();
