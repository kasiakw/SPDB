/* Zwraca 1, jesli wielokat o geom_nr o_id przecina siê z wielokatem o numerze g_nr,
w przeciwnym wypadku zwraca 0.
Zaklada sie, ze wielokaty sa wypukle, dlatego procedura polega na
sprawdzeniu zawierania wierzcholkow wewnatrz wielokata (funkcja zawiera_punkt).
Wystarczy, ¿e chociaz jeden wierzcholek wielokata znajduje sie w drugim wielokacie.
*/ 
CREATE OR REPLACE FUNCTION przeciecie
   (g_nr IN NUMBER, o_id IN NUMBER) 
    RETURN NUMBER 
    IS 
    res NUMBER(1);
    TYPE coord_array IS VARRAY(10) OF NUMBER(5,2);
    x1_coords coord_array;
    y1_coords coord_array;
    x2_coords coord_array;
    y2_coords coord_array;
    x_point NUMBER(5,2);
    y_point NUMBER(5,2);
    n_out NUMBER(2);
    n_in NUMBER(2);
    j NUMBER(2);
    flaga BOOLEAN;
BEGIN
      select x BULK COLLECT into x1_coords from country where geom_nr = g_nr;
      select y BULK COLLECT into y1_coords from country where geom_nr = g_nr;

      select x BULK COLLECT into x2_coords from country where geom_nr = o_id;
      select y BULK COLLECT into y2_coords from country where geom_nr = o_id;   
      n_out :=  x1_coords.COUNT;
      n_in :=  x2_coords.COUNT;
      
      /* czy ktorys z wierzcholkow II wielokata znajduje sie wewn¹trz I */
      FOR k IN 1 .. n_in LOOP
        j :=  n_out;
        flaga := FALSE;
        x_point := x2_coords(k);
        y_point := y2_coords(k);        
        res := 0;
        
        FOR i IN 1 .. n_out LOOP
          IF
          ((y1_coords(i) > y_point) != (y1_coords(j) > y_point) AND
          (x_point < (x1_coords(j) - x1_coords(i)) * (y_point - y1_coords(i)) / (y1_coords(j) - y1_coords(i)) + x1_coords(i)))
          THEN
          flaga := NOT flaga;
          END IF;
          j := i;
        END LOOP;
      
        IF FLAGA THEN
          res := 1;
          RETURN res; 
        END IF;        
      END LOOP;

      /* czy ktorys z wierzcholkow I wielokata znajduje sie wewn¹trz II */
      FOR k IN 1 .. n_out LOOP
        j :=  n_in;
        flaga := FALSE;
        x_point := x1_coords(k);
        y_point := y1_coords(k);        
        res := 0;
        
        FOR i IN 1 .. n_in LOOP
          IF
          ((y2_coords(i) > y_point) != (y2_coords(j) > y_point) AND
          (x_point < (x2_coords(j) - x2_coords(i)) * (y_point - y2_coords(i)) / (y2_coords(j) - y2_coords(i)) + x2_coords(i)))
          THEN
          flaga := NOT flaga;
          END IF;
          j := i;
        END LOOP;
      
        IF FLAGA THEN
          res := 1;
          RETURN res; 
        END IF;        
      END LOOP; 
      
    RETURN res;     
END;

/* aby wypisac bledy
alter function przeciecie compile plsql_warnings='ENABLE:ALL' reuse settings;
alter function zawiera_obiekt compile plsql_warnings='ENABLE:ALL' reuse settings;

select *
from   user_errors ur
where  ur.name = 'PRZECIECIE';
*/