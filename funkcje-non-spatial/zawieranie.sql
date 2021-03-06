/* Zwraca 1, jesli punkt o id point_id z tabeli CITY znajduje si� wewnatrz wielokata o numerze g_nr,
w przeciwnym wypadku zwraca 0.
https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
*/ 
CREATE OR REPLACE FUNCTION zawiera_punkt
   (g_nr IN NUMBER, point_id IN NUMBER) 
    RETURN NUMBER 
    IS 
    res NUMBER(1);
    TYPE coord_array IS VARRAY(10) OF NUMBER(5,2);
    x_coords coord_array;
    y_coords coord_array;
    x_point NUMBER(5,2);
    y_point NUMBER(5,2);
    n NUMBER(2);
    j NUMBER(2);
    flaga BOOLEAN;
BEGIN
      select x BULK COLLECT into x_coords from country where geom_nr = g_nr;
      select y BULK COLLECT into y_coords from country where geom_nr = g_nr;
      select x into x_point from city where gid = point_id;
      select y into y_point from city where gid = point_id;
      n :=  x_coords.COUNT;
      j :=  n;
      res := 0;
      flaga := FALSE;
      
      FOR i IN 1 .. n LOOP
        IF
        ((y_coords(i) > y_point) != (y_coords(j) > y_point) AND
        (x_point < (x_coords(j) - x_coords(i)) * (y_point - y_coords(i)) / (y_coords(j) - y_coords(i)) + x_coords(i)))
        THEN
        flaga := NOT flaga;
        END IF;
        j := i;
      END LOOP;
      
      IF FLAGA THEN
      res := 1;
      END IF;
      
      RETURN res;     
END;

/* Zwraca 1, jesli wielokat o geom_nr o_id znajduje si� wewnatrz wielokata o numerze g_nr,
w przeciwnym wypadku zwraca 0.
Zaklada sie, ze wielokaty sa wypukle, dlatego procedura polega na
sprawdzeniu zawierania wierzcholkow wewnatrz wielokata (funkcja zawiera_punkt)
*/
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION zawiera_wielokat
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
      
      -- dla kazdego punktu wielokata zawieranego
      FOR k IN 1 .. n_in LOOP
        j :=  n_out;
        flaga := FALSE;
        x_point := x2_coords(k);
        y_point := y2_coords(k);        
        res := 1;
        
        -- dla kazdego punktu wielokata zawierajacego
        FOR i IN 1 .. n_out LOOP
          IF
          ((y1_coords(i) > y_point) != (y1_coords(j) > y_point) AND
          (x_point < (x1_coords(j) - x1_coords(i)) * (y_point - y1_coords(i)) / (y1_coords(j) - y1_coords(i)) + x1_coords(i)))
          THEN
          flaga := NOT flaga;
          END IF;
          j := i;
        END LOOP;
      
        IF FLAGA = FALSE THEN
          res := 0;
          RETURN res; 
        END IF;
        
      END LOOP;  
      
      RETURN res;     
END;

/* Zwraca 1, jesli odcinek o id o_id znajduje si� wewnatrz wielokata o numerze g_nr,
w przeciwnym wypadku zwraca 0.
Zaklada sie, ze wielokaty sa wypukle, dlatego procedura polega na
sprawdzeniu zawierania punkt�w pierwszego oraz ko�cowego odcinka wewnatrz wielokata (funkcja zawiera_punkt)
*/
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION zawiera_odcinek
   (g_nr IN NUMBER, o_id IN NUMBER) 
    RETURN NUMBER 
    IS 
    res NUMBER(1);
    TYPE coord_array IS VARRAY(10) OF NUMBER(5,2);
    x1_coords coord_array;
    y1_coords coord_array;
    x_point NUMBER(5,2);
    y_point NUMBER(5,2);
    x11 NUMBER(5,2);
    y11 NUMBER(5,2);
    x22 NUMBER(5,2);
    y22 NUMBER(5,2);
    n_out NUMBER(2);
    j NUMBER(2);
    flaga BOOLEAN;
BEGIN
      select x BULK COLLECT into x1_coords from country where geom_nr = g_nr;
      select y BULK COLLECT into y1_coords from country where geom_nr = g_nr;

      select x1 into x11 from river where gid = o_id;
      select y1 into y11 from river where gid = o_id;
      select x2 into x22 from river where gid = o_id;
      select y2 into y22 from river where gid = o_id;
       
      n_out :=  x1_coords.COUNT;
      
      j :=  n_out;
      flaga := FALSE;
      x_point := x11;
      y_point := y11;        
      res := 1;        
      -- dla kazdego punktu wielokata zawierajacego
      FOR i IN 1 .. n_out LOOP
        IF
          ((y1_coords(i) > y_point) != (y1_coords(j) > y_point) AND
          (x_point < (x1_coords(j) - x1_coords(i)) * (y_point - y1_coords(i)) / (y1_coords(j) - y1_coords(i)) + x1_coords(i)))
        THEN
          flaga := NOT flaga;
        END IF;
          j := i;
      END LOOP;
      
      IF FLAGA = FALSE THEN
        res := 0;
        RETURN res; 
      END IF;
        
      j :=  n_out;
      flaga := FALSE;
      x_point := x22;
      y_point := y22;        
      res := 1;        
      -- dla kazdego punktu wielokata zawierajacego
      FOR i IN 1 .. n_out LOOP
        IF
          ((y1_coords(i) > y_point) != (y1_coords(j) > y_point) AND
          (x_point < (x1_coords(j) - x1_coords(i)) * (y_point - y1_coords(i)) / (y1_coords(j) - y1_coords(i)) + x1_coords(i)))
        THEN
          flaga := NOT flaga;
        END IF;
          j := i;
      END LOOP;
      
      IF FLAGA = FALSE THEN
        res := 0;
      END IF;
              
    RETURN res;     
END;

/* aby wypisac bledy
alter function zawiera_punkt compile plsql_warnings='ENABLE:ALL' reuse settings;
alter function zawiera_obiekt compile plsql_warnings='ENABLE:ALL' reuse settings;

select *
from   user_errors ur
where  ur.name = 'ZAWIERA_PUNKT';

select *
from   user_errors ur
where  ur.name = 'ZAWIERA_WIELOKAT';

select *
from   user_errors ur
where  ur.name = 'ZAWIERA_ODCINEK';
*/