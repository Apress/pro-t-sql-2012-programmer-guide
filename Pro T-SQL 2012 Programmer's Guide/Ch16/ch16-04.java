import java.sql.*;

public class ApressExample {

	public static void main(String[] args) {
		
		String connectionUrl = "jdbc:sqlserver://SQL2012;integratedSecurity=true;databaseName=AdventureWorks;failoverPartner=SQL2012B";
		Connection cn = null;
		String qry = "SELECT TOP 10 FirstName, LastName FROM Person.Contact";
		
		try {
			cn = DriverManager.getConnection(connectionUrl);
			runQuery(cn, qry);
		} catch (SQLException se) {
			try {
				System.out.println("Connection to principal server failed, trying the mirror server.");
				cn = DriverManager.getConnection(connectionUrl);
				runQuery(cn, qry);
			} catch (Exception e) {
				e.printStackTrace();
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (cn != null) try { cn.close(); } catch(Exception e) { }
      }
   }
   
	private static void runQuery(Connection cn, String SQL) {
		Statement stmt = null;
		ResultSet rs = null;

		try {
			stmt = cn.createStatement();
			rs = stmt.executeQuery(SQL);

			while (rs.next()) {
				System.out.println(rs.getString(0));
			}
			rs.close();
			stmt.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (rs != null) try { rs.close(); } catch(Exception e) {}
			if (stmt != null) try { stmt.close(); } catch(Exception e) {}
		}
	}
}
