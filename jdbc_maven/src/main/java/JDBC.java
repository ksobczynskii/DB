import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class JDBC {
    public JDBC(){}

    public static void main(String[] args)
    {
        Connection con = null;
        try{
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=Northwind;encrypt=true;trustServerCertificate=true", "sa", "Czosnek007");
            Statement statement = con.createStatement();
            ResultSet rs = statement.executeQuery("SELECT * FROM dbo.Employees");
            while(rs.next()){
                System.out.println("Employee: " + rs.getString("FirstName") + " " + rs.getString("LastName"));
            }
            statement.close();
            rs.close();
            con.close();
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
    }
}
