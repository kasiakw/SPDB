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

  //dodalam do nazw tabel przedrostki system., bo u mnie siê znajduja w schemacie system
  String s_query1 = "SELECT gid FROM system.country_geom c " + 
		  "WHERE SDO_CONTAINS(c.geom, (SELECT point FROM system.city_geom p where p.gid = 10)) = 'TRUE'";
  String s_query2 = "SELECT COUNT(*) FROM system.country_geom";
  
  String query1 = "SELECT geom_nr FROM system.country WHERE system.zawiera_punkt(geom_nr, 10) = 1 " +
		  "GROUP BY geom_nr";
  try
   {
	  DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
	  
	  System.out.println("Sterowniki za³adowane");
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
	                          "nie uda³o siê  po³¹czyæ  z baz¹  danych", ex); 
	         System.exit(-1); 
	  }     
	  System.out.println("Po³¹czenie nawi¹zane");
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
    	  conn.commit();
	  }
	  catch (SQLException ex) { 
		    System.out.println("B³ad wykonania polecenia" + ex.toString());
		    conn.rollback();
	  } 
	  finally {
    	    zapis.close();
		    if (stm != null) { 
		         try { 
		             stm.close(); 
		             System.out.println("Statement zamkniêty"); 
		         } catch (SQLException e) { System.out.println("Nie udalo sie zamknac res." + e.toString()); } 
		    } 
		    if (conn != null) { 
		         try { 
		           conn.close();
		           System.out.println("Po³¹czenie zakoñczone"); 
		         } catch (SQLException e) { System.out.println("Nie udalo sie zamknac stm." + e.toString()); } 
		    } 
	  } 

  }
  catch(Exception e)
  {  
	  System.out.println("B³¹d");
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

