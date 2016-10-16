SqlCommand command = new SqlCommand
  (
    "SELECT COUNT(*) " +
    "FROM Person.Person;", sqlconnection
  );
Object count = command.ExecuteScalar();
