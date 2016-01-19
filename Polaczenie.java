import java.sql.*; 
import java.util.Properties; 
import java.util.logging.Level; 
import java.util.logging.Logger;
import java.io.PrintWriter;

/** Aplikacja testowa, mierzy czas odpowiedzi na rezultaty wybranych zapytan (w ms), 
 *  (nalezy zebrac na nowo statystyki (dbms_stats) po kazdej zmianie schematu tabel/indeksow lub 
 *  zawartych w nich danych */
public class Polaczenie {
 
 public void polaczenie_z_baza() 
 {
	 							//@adres serwera:port:nazwa bazy
  String baza = "jdbc:oracle:thin:@localhost:1521:orcl";
  
  /* wyczyszczenie bufora bazy danych oraz obszaru dzielonego - 
  usuniecie wynikow i planow wykonan poprzednich zapytan, zachowanie niezaleznosci testow */
  String buffer	= "ALTER SYSTEM FLUSH BUFFER_CACHE";
  String shared = "ALTER SYSTEM FLUSH SHARED_POOL";

  //zawieranie punktu
  // TODO: zmieni� p.gid na wy�szy (mozliwe do zrobienia dopiero po wiekszym insercie)
  String s_query1 = "SELECT gid FROM system.country_geom c " + 
		  "WHERE SDO_CONTAINS(c.geom, (SELECT point FROM system.city_geom p where p.gid = 10)) = 'TRUE'";
  String query1 = "SELECT geom_nr FROM system.country WHERE system.zawiera_punkt(geom_nr, 10) = 1 " +
		  "GROUP BY geom_nr";
  
  //przeciecie: zwraca obiekty majace czesc wspolna z danym
  String s_query2 = "";
  String query2 = "";
  
  //zawieranie odcinka: zwraca odcinki zawarte w danym wielokacie
  String s_query30 = "SELECT r.gid FROM system.country_geom c, system.river_geom r " +
		  "WHERE SDO_RELATE(c.geom, r.line, 'mask=CONTAINS') = 'TRUE'";
  String query30 = "SELECT r.gid FROM system.country c, system.river r " +
		  "WHERE system.zawiera_obiekt(c.geom_nr, r.gid, 1) = 1 GROUP BY r.gid";
  
  //zawieranie wielokata: zwraca wielokaty zawarte w danym wielokacie 
  String s_query31 = "SELECT b.gid FROM system.country_geom a, system.country_geom b " +
		  "WHERE SDO_RELATE(a.geom, b.geom, 'mask=CONTAINS') = 'TRUE'";
  String query31 = "SELECT b.geom_nr FROM system.country a, system.country b " +
		  "WHERE system.zawiera_obiekt(a.geom_nr, b.geom_nr, 1) = 1 GROUP BY b.geom_nr";
  
  //zwracanie k-najblizszych sasiadow
  String s_query4 = "";
  String query4 = "";
  
  //obliczanie pola wybranego wielokata
  // TODO: zmieni� gid na wy�szy (mozliwe do zrobienia dopiero po wiekszym insercie)
  String s_query5 = "SELECT SDO_GEOM.sdo_area(geom, 1, '') FROM system.country_geom WHERE gid = 9";
  String query5 = "SELECT geom_nr, system.pole_figury(geom_nr)  FROM system.country WHERE geom_nr = 9 " + 
		  "GROUP BY geom_nr";
  
  //obliczanie odleglosci
  String s_query6 = "SELECT c.gid, SDO_NN_DISTANCE(1) " +
                "  FROM system.country_geom c , system.country_geom c2 " +
                "  where c2.gid = 1 " +
                "  AND SDO_NN(c.GEOM, c2.GEOM,'sdo_num_res=10',1) = 'TRUE' ";
  String query6 = "SELECT c.geom_nr, system.odleglosc(1, geom_nr) " +
                "  FROM system.country c ";
  

  try
   {
	  DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
	  
	  System.out.println("Sterowniki za�adowane");
	  Connection conn = null;
	  try
	  {
		  Properties props = new Properties();
		  props.put("user", "SYS");
		  props.put("password", "oracle");
		  props.put("internal_logon", "SYSDBA"); 
		  conn = DriverManager.getConnection(baza, props);
	  }
	  catch (SQLException ex) { 
	         Logger.getLogger(Polaczenie.class.getName()).log(Level.SEVERE,   
	                          "nie uda�o si�  po��czy�  z baz�  danych", ex); 
	         System.exit(-1); 
	  }     
	  System.out.println("Po��czenie nawi�zane");
	  Statement stm = null;
	  PrintWriter zapis = new PrintWriter("dane.txt");
	  try 
	  {
		  conn.setAutoCommit(false);
		  stm =conn.createStatement();
          
          stm.executeUpdate(buffer);
          stm.executeUpdate(shared);
          
          test(stm, s_query1, zapis);
          test(stm, query1, zapis);
          //test(stm, s_query2, zapis);
          //test(stm, query2, zapis);
          test(stm, s_query30, zapis);
          test(stm, query30, zapis);
          test(stm, s_query31, zapis);
          test(stm, query31, zapis);
          //test(stm, s_query4, zapis);
          //test(stm, query4, zapis);
          test(stm, s_query5, zapis);
          test(stm, query5, zapis);
          //test(stm, s_query6, zapis);
          //test(stm, query6, zapis); 
    	  conn.commit();
	  }
	  catch (SQLException ex) { 
		    System.out.println("B�ad wykonania polecenia" + ex.toString());
		    conn.rollback();
	  } 
	  finally {
    	    zapis.close();
		    if (stm != null) { 
		         try { 
		             stm.close(); 
		             System.out.println("Statement zamkni�ty"); 
		         } catch (SQLException e) { System.out.println("Nie udalo sie zamknac res." + e.toString()); } 
		    } 
		    if (conn != null) { 
		         try { 
		           conn.close();
		           System.out.println("Po��czenie zako�czone"); 
		         } catch (SQLException e) { System.out.println("Nie udalo sie zamknac stm." + e.toString()); } 
		    } 
	  } 

  }
  catch(Exception e)
  {  
	  System.out.println("B��d");
	  e.printStackTrace();
  }
 }
 
private void test(Statement stm, String query, PrintWriter zapis) throws Exception
{
	  long start = System.currentTimeMillis(); 
	  ResultSet res = stm.executeQuery(query);
	  long time = System.currentTimeMillis() - start;

	  res.close();
	  System.out.println("Czas: " + time + " ms dla zapytania " + query + ";");
      zapis.println("Czas: " + time + " ms dla zapytania " + query + ";" + '\n');
	
}
 
public static void main(String[] args){
  Polaczenie oracle =new Polaczenie();
  oracle.polaczenie_z_baza();  
}
}

