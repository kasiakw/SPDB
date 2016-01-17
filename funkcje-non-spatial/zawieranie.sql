/* Zwraca 1, jesli punkt o id point_id z tabeli CITY znajduje siê wewnatrz wielokata o numerze g_nr,
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

/* Zwraca 1, jesli obiekt o id o_id znajduje siê wewnatrz wielokata o numerze g_nr,
w przeciwnym wypadku zwraca 0.
Obiektem zawieranym mo¿e byæ odcinek (type = 0) lub inny wielokat (otype = 1).
Dla odcinków o_id to gid z tabeli RIVER, zaœ dla wielokatow o_id to geom_nr z tabeli COUNTRY.
Zaklada sie, ze wielokaty sa wypukle, dlatego procedura polega na
sprawdzeniu zawierania wierzcholkow wewnatrz wielokata (funkcja zawiera_punkt)
*/ 
CREATE OR REPLACE FUNCTION zawiera_obiekt
   (g_nr IN NUMBER, o_id IN NUMBER, o_type IN NUMBER) 
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

      IF o_type = 1 THEN
        select x BULK COLLECT into x2_coords from country where geom_nr = o_id;
        select y BULK COLLECT into y2_coords from country where geom_nr = o_id;
      ELSIF o_type = 0 THEN
        select x1 into x2_coords(1) from river where gid = o_id;
        select y1 into y2_coords(1) from river where gid = o_id;
        select x2 into x2_coords(2) from river where gid = o_id;
        select y2 into y2_coords(2) from river where gid = o_id;
      ELSE
        DBMS_OUTPUT.PUT_LINE('ZLY TYP OBIEKTU ZAWIERANEGO (moze byc 0 lub 1)');
        RETURN 0;
      END IF;      
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

/* aby wypisac bledy
alter function zawiera_punkt compile plsql_warnings='ENABLE:ALL' reuse settings;
alter function zawiera_obiekt compile plsql_warnings='ENABLE:ALL' reuse settings;

select *
from   user_errors ur
where  ur.name = 'ZAWIERA_PUNKT';

select *
from   user_errors ur
where  ur.name = 'ZAWIERA_OBIEKT';
*/