/* count area with shoelace formula */
CREATE OR REPLACE FUNCTION pole_figury
   (g_nr IN NUMBER) 
    RETURN NUMBER 
    IS 
    res NUMBER(10,2);
    TYPE coord_array IS VARRAY(30) OF NUMBER(5,2);
    x_coords coord_array;
    y_coords coord_array;
    
    xa NUMBER(5,2);
    xb NUMBER(5,2);
    xc NUMBER(5,2);
    xd NUMBER(5,2);
    xe NUMBER(5,2);
    
    ya NUMBER(5,2);
    yb NUMBER(5,2);
    yc NUMBER(5,2);
    yd NUMBER(5,2);
    ye NUMBER(5,2);
    
    n NUMBER(2);
    
BEGIN
      select x BULK COLLECT into x_coords from country where geom_nr = g_nr;
      select y BULK COLLECT into y_coords from country where geom_nr = g_nr;
      
      n :=  x_coords.COUNT;
      /*
      aa := 2;
      bb := 3;
      */
      xa := x_coords(1);
      xb := x_coords(2);
      xc := x_coords(3);
      
      ya := y_coords(1);
      yb := y_coords(2);
      yc := y_coords(3);
      
      IF n = 3 THEN
        res := 0.5 * ABS((xa - xc)*(yb - ya) - (xa - xb)*(yc - ya));
      ELSIF n = 4 THEN
        xd := x_coords(4);
        yd := y_coords(4);
        
        res := 0.5 * ABS( (xa*yb + xb*yc + xc*yd + xd*ya) - 
                          (xb*ya + xc*yb + xd*yc + xa*yd) );
        /*
        aa := SQRT(POWER(x_coords(1)-x_coords(2), 2) + POWER(y_coords(1) - y_coords(2),2));
        bb := SQRT(POWER(x_coords(2)-x_coords(3), 2) + POWER(y_coords(2) - y_coords(3),2));
        res := aa * bb ;
        */
      ELSIF n = 5 THEN
        xd := x_coords(4);
        yd := y_coords(4);
        xe := x_coords(5);
        ye := y_coords(5);
        res := 0.5 * ABS( (xa*yb + xb*yc + xc*yd + xd*ye + xe*ya) - 
                          (xb*ya + xc*yb + xd*yc + xe*yd + xa*ye) );
      ELSE 
        res := 0;
      END IF;

      RETURN res;     
END;


/*zapytanie do niego*/
SELECT c.geom_nr, system.pole_figury(geom_nr)
  FROM country c 
;

/*
alter function pole_figury compile plsql_warnings='ENABLE:ALL' reuse settings;
*/
select *
from   user_errors ur
where  ur.name = 'POLE_FIGURY';