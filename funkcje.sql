/* zwraca 1, jesli punkt o id point_id z tabeli CITY znajduje siê wewnatrz wielokata o numerze g_nr;
w przeciwnym wypadku zwraca 0
https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
*/ 
CREATE OR REPLACE FUNCTION zawiera_punkt
   (g_nr IN NUMBER, point_id IN NUMBER) 
    RETURN NUMBER 
    IS 
    res NUMBER(1);
    TYPE coord_array IS VARRAY(30) OF NUMBER(5,2);
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

/* aby wypisac bledy
alter function zawiera_punkt compile plsql_warnings='ENABLE:ALL' reuse settings;

select *
from   user_errors ur
where  ur.name = 'ZAWIERA_PUNKT';
*/