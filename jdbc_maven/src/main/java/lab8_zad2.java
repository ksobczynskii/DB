
import java.sql.*;

public class lab8_zad2
{
     lab8_zad2(){}

        public static void main(String[] args)
        {
            Connection con = null;
            try{
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                con = DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=Northwind;encrypt=true;trustServerCertificate=true", "sa", "Czosnek007");
                con.setAutoCommit(false);
                Statement statement = con.createStatement();
                InsertTwoNewEmployees("Colonel","Sanders", "Korpo","Dziad",con);
//                statement.executeQuery("INSERT INTO dbo.Employees (LastName, FirstName) VALUES ('"+ last1 + "', '" + first1 + "'), ('"+last2+"', '"+first2+"')");
                UpdateEmployeeLastName(13, "Goli-zadek", con);
//                statement.close();
//                rs.close()
//                ;
                con.commit();
                var result = statement.executeQuery("SELECT * FROM ORDERS");

                for (int i = 0; i < 10; i++) {
                    InsertRandomSingleOrder(result, con);
                }
                con.commit();
                statement.close();
                con.close();

            }
            catch(Exception e)
            {
                e.printStackTrace();
            }
        }
        public static void InsertTwoNewEmployees(String first1, String last1, String first2, String last2, Connection con)
        {
            try{
                String sql = "INSERT INTO dbo.Employees (LastName, FirstName) VALUES (?, ?), (?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1,last1);
                ps.setString(2,first1);
                ps.setString(3,last2);
                ps.setString(4,first2);
                var inserted = ps.executeUpdate();

                System.out.println("Added " + inserted + "Rows");
                ps.close();
//                var res = statement.executeQuery("INSERT INTO dbo.Employees (LastName, FirstName) VALUES ('"+ last1 + "', '" + first1 + "'), ('"+last2+"', '"+first2+"')");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        public static void UpdateEmployeeLastName(Integer employeeId, String newLastName, Connection con)
        {
            try{
                String sql = "UPDATE Employees SET LastName = ? WHERE EmployeeId = ?";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1,newLastName);
                ps.setInt(2,employeeId);
                var inserted = ps.executeUpdate();

                System.out.println("Updated " + inserted + " Rows");

                ps.close();
//                var res = statement.executeQuery("UPDATE Employees SET LastName = '" + newLastName + "' WHERE EmployeeId = '" + employeeId + "'");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        public static void InsertRandomSingleOrder(ResultSet rs, Connection con)
        {
            try{
                if(rs.next())
                {
                    String sql = "INSERT INTO Orders (CustomerId, EmployeeID, OrderDate, ShipName) VALUES (?,?,?,?)";
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1,rs.getString("CustomerId"));
                    ps.setInt(2,rs.getInt("EmployeeId"));
                    ps.setDate(3,rs.getDate("OrderDate"));
                    ps.setString(4,"FELIZ NAVIDAD!!!!!!");

                    var edited = ps.executeUpdate();

                    System.out.println("Edited " + edited + " Rows");
                    ps.close();
                }
            }
            catch (Exception e)
            {
                e.printStackTrace();
            }
        }
}
