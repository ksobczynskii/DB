import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.*;

public class GokartyApplication {
    GokartyApplication(){}

    public static void main(String[] args)
    {
//        Connection con = null;
        try(Connection con = DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=GOKARTY_3;encrypt=true;trustServerCertificate=true", "user", "xyz")
        ) {
            con.setAutoCommit(false);
            // TRANSACTION 1:
            Statement st = con.createStatement();
//            ResultSet rs = st.executeQuery("SELECT x = MIN(g.stan_magazynu) FROM GOKARTY g");

//            int x = -1;
//            while(rs.next()){
//                x = rs.getInt("x");
//                if(x > 0)
//                    System.out.println("Najniższy stan magazynu to: " + rs.getInt("x"));
//                else
//                    System.out.println("Nie ma rekordów!");
//            }
//            if(x > 0)
//            {
//                var res = st.executeUpdate("DELETE GOKARTY WHERE stan_magazynu = " + x);
//                System.out.println("Usunięto " + res + " Rekordów");
//            }
//
//            con.commit();
//            rs.close();


            // TRANSAKCJA 2

//            var res = st.executeUpdate("INSERT INTO GOKARTY " +
//                    "(model, opis, data_zakupu, cena_za_godzine, stan_magazynu, wartosc_zapasow)" +
//                    "VALUES" +
//                    "(" + "'" +  "BMW M5" +"',"+ "'"+ "Szybkie fursko" +"',"+ "2020-07-12" +","+ 88.00 + 5 +","+ (5*88.00)+ ")" +
//                    "(" +"'"+ "Audi Q9" +"',"+ "'" + "Srednie fursko" +"',"+ "2022-09-03" +","+ 76.00 +","+ 7 +","+ (7*76.00) + ")" +
//                    "(" + "'" +"Mercedes Viano" +"',"+ "'" +"MI BOMBOCLATTTT" +"',"+ "2014-03-22" +","+ 112.00 +","+ 8+ (8*112.00) + ")" +
//                    "(" + "'" +"Grok.AI" +"',"+ "'"+ "CO tu robi grock" +"',"+ "2024-12-25" +","+ 3.00 + 10 +","+ (3*10.00) + ")");

//            PreparedStatement ps = con.prepareStatement("INSERT INTO GOKARTY (model, opis, data_zakupu, cena_za_godzine, stan_magazynu, wartosc_zapasow) VALUES (?,?,?,?,?,?),(?,?,?,?,?,?), (?,?,?,?,?,?), (?,?,?,?,?,?)");
//            ps.setString(1,"BMW M5");
//            ps.setString(2,"Szybkie fursko");
//            ps.setDate(3,Date.valueOf("2020-07-12"));
//            ps.setDouble(4,88.00);
//            ps.setInt(5,5);
//            ps.setDouble(6,88.00*5);
//            ps.setString(7,"Audi Q9");
//            ps.setString(8,"Srednie fursko");
//            ps.setDate(9,Date.valueOf("2022-09-03"));
//            ps.setDouble(10,76.00);
//            ps.setInt(11,7);
//            ps.setDouble(12,76.00*7);
//            ps.setString(13,"Mercedes Viano");
//            ps.setString(14,"MI BOMBOCLATTTT");
//            ps.setDate(15,Date.valueOf("2014-03-22"));
//            ps.setDouble(16,112.00 );
//            ps.setInt(17,8);
//            ps.setDouble(18,112.00*8);
//            ps.setString(19,"Grok.AI");
//            ps.setString(20,"CO tu robi grock");
//            ps.setDate(21,Date.valueOf("2024-12-25"));
//            ps.setDouble(22,3.00);
//            ps.setInt(23,10);
//            ps.setDouble(24,3.00*10);
//
//            var res = ps.executeUpdate();
//            System.out.println("Dodano " + res + " nowych gokartów");

//            con.commit();



            // TRANSAKCJA 3
//            var res = st.executeUpdate("UPDATE GOKARTY SET stan_magazynu = stan_magazynu +2");
//            st.executeUpdate("UPDATE GOKARTY SET wartosc_zapasow = stan_magazynu*cena_za_godzine");
//            System.out.println("Powiekszono o 2 sztuki w magazynie " + res + " gokartów");
//            PreparedStatement ps = con.prepareStatement("INSERT INTO GOKARTY (model, opis, data_zakupu, cena_za_godzine, stan_magazynu, wartosc_zapasow) VALUES (?,?,?,?,?,?)");
//            ps.setString(1,"GoatCart");
//            ps.setString(2,"do ozbaczenia w sektorze neibo");
//            ps.setDate(3,Date.valueOf("2026-04-29"));
//            ps.setDouble(4,1000.00/3.0);
//            ps.setInt(5,3);
//            ps.setDouble(6,1000.00);
//
//            res = ps.executeUpdate();
//            System.out.println("Dodano Gokart!");
//
//            con.commit();

            // TRANSAKCJA 4
            PreparedStatement ps = con.prepareStatement("INSERT INTO GOKARTY (model, opis, data_zakupu, cena_za_godzine, stan_magazynu, wartosc_zapasow) VALUES"  + "(?,?,?,?,?,?)" +  ",(?,?,?,?,?,?)".repeat(9));

            for(int i=0; i<10;i++)
            {
                ps.setString(6*i+1,"Gokarcik no." + i);
                ps.setString(2+i*6,"do ozbaczenia w sektorze neibo gokarciku no " + i);
                ps.setDate(3+i*6,Date.valueOf("2026-04-30"));
                ps.setDouble(4+i*6,10.00);
                ps.setInt(5+i*6,2+i);
                ps.setDouble(6+i*6,10.00*(2+i));
            }

            ps.executeUpdate();

            var LeastCars = st.executeQuery("SELECT id, data_zakupu FROM GOKARTY WHERE stan_magazynu = (SELECT MIN(stan_magazynu) FROM GOKARTY)");
            LeastCars.next();
            int id_least = LeastCars.getInt("id");
            String date_least = LeastCars.getString("data_zakupu");
            LeastCars.close();

            var MostCars = st.executeQuery("SELECT id, data_zakupu FROM GOKARTY WHERE stan_magazynu = (SELECT MAX(stan_magazynu) FROM GOKARTY)");
            MostCars.next();
            int id_most = MostCars.getInt("id");
            String date_most = MostCars.getString("data_zakupu");
            MostCars.close();

            System.out.println("Znaleziony min = " + id_least + " i max = " + id_most);
            var swap1 = st.executeUpdate("UPDATE GOKARTY SET data_zakupu = '" + date_least +"' WHERE id = " + id_most);
            System.out.println("Zmieniono " + swap1 + " Wierszy!");

            var swap2 = st.executeUpdate("UPDATE GOKARTY SET data_zakupu = '"+date_most+"' WHERE id = " + id_least);
            System.out.println("Zmieniono " + swap2 + " Wierszy!");


            con.commit();

            ps.close();
//
//
//
//
//
//


            st.close();


        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        finally{
            System.out.println("Ended the process");
        }
    }

}
