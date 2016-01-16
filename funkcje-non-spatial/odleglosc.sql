/* count area with shoelace formula */
CREATE OR REPLACE FUNCTION odleglosc
   (g1_nr IN NUMBER, g2_nr IN NUMBER)
    RETURN NUMBER 
    IS 
    res NUMBER(10,2);
    TYPE coord_array IS VARRAY(30) OF NUMBER(5,2);
    x1_coords coord_array;
    y1_coords coord_array;
    x2_coords coord_array;
    y2_coords coord_array;
    
    dist NUMBER(8,2);
    smallest_dist NUMBER(8,2);
    
    x0 NUMBER(5,2);
    y0 NUMBER(5,2);
    
    x1 NUMBER(5,2);
    x2 NUMBER(5,2);
    y1 NUMBER(5,2);
    y2 NUMBER(5,2);
    
    n1 NUMBER(2);
    n2 NUMBER(2);
    
BEGIN
      select x BULK COLLECT into x1_coords from country where geom_nr = g1_nr;
      select y BULK COLLECT into y1_coords from country where geom_nr = g1_nr;
      select x BULK COLLECT into x2_coords from country where geom_nr = g2_nr;
      select y BULK COLLECT into y2_coords from country where geom_nr = g2_nr;
      
      n1 :=  x1_coords.COUNT;
      n2 :=  x2_coords.COUNT;
      
      smallest_dist := 100000;
      
      FOR start_coord in 1 .. n1 LOOP
        FOR end_coord in 1 .. n1 LOOP
          IF start_coord = end_coord 
          THEN 
            continue;
          end if;
          
          FOR i IN 1 .. n2 LOOP
            x1 := x1_coords(start_coord);
            y1 := y1_coords(start_coord);
            x2 := x1_coords(end_coord);
            y2 := y1_coords(end_coord);
            
            x0 := x2_coords(i);
            y0 := y2_coords(i);
        
            dist := ( ABS( (y2-y1)*x0 - (x2-x1)*y0 + x2*y1 - y2*x1 ) )
                      / ( SQRT( POWER(y2 - y1, 2) + POWER(x2-x1, 2)) );
            IF dist < smallest_dist 
            THEN 
              smallest_dist := dist;
            END IF;
      
          END LOOP;
        END LOOP;
      END LOOP;
      RETURN smallest_dist;
END;



select *
from   user_errors ur
where  ur.name = 'ODLEGLOSC';
