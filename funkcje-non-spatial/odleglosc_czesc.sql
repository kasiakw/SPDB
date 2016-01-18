/* oblicza odleglosci pomiedzy wszystkimi odcinkami figury 1 a wszystkimi punktami figury 2, zwraca najmniejsz¹ odeglosc*/

CREATE OR REPLACE FUNCTION odleglosc_czesc
   (g1_nr IN NUMBER, g2_nr IN NUMBER)
    RETURN NUMBER 
    IS 
    TYPE coord_array IS VARRAY(30) OF NUMBER(10,2);
    x1_coords coord_array;
    y1_coords coord_array;
    x2_coords coord_array;
    y2_coords coord_array;
    
    dist NUMBER(8,2);
    smallest_dist NUMBER(8,2);
    aa NUMBER(8,2);
    bb NUMBER(8,2);
    xL NUMBER(5,2);
    yL NUMBER(5,2);
    x0 NUMBER(5,2);
    y0 NUMBER(5,2);
    x1 NUMBER(5,2);
    x2 NUMBER(5,2);
    y1 NUMBER(5,2);
    y2 NUMBER(5,2);
    
    n1 NUMBER(3);
    n2 NUMBER(3);
    
    dotproduct NUMBER(10,2);
    
BEGIN
      select x BULK COLLECT into x1_coords from country where geom_nr = g1_nr;
      select y BULK COLLECT into y1_coords from country where geom_nr = g1_nr;
      select x BULK COLLECT into x2_coords from country where geom_nr = g2_nr;
      select y BULK COLLECT into y2_coords from country where geom_nr = g2_nr;
      
     /* DBMS_OUTPUT.PUT_LINE('n1 ' ||  x1_coords.COUNT);
      DBMS_OUTPUT.PUT_LINE('n2 ' ||  x2_coords.COUNT); */
      
      n1 :=  x1_coords.COUNT;
      n2 :=  x2_coords.COUNT;
      
      smallest_dist := 10000;
      FOR start_coord in 1 .. (n1-1) LOOP
        /*FOR end_coord in (start_coord+1) .. n1 LOOP*/
          
          FOR i IN 1 .. n2 LOOP
            x1 := x1_coords(start_coord);
            y1 := y1_coords(start_coord);
            x2 := x1_coords(start_coord+1);
            y2 := y1_coords(start_coord+1);
            
            x0 := x2_coords(i);
            y0 := y2_coords(i);
            
            aa := (y2 - y1) / (x2 - x1);
            bb := y1 - aa * x1;
            
            xL := ( x0 + aa*y0 - aa*bb ) / ( aa*aa + 1 );
            yL := aa * xL + bb;
            
            dotproduct := (xL - x1)*(x2 - x1) + (yL - y1)*(y2 - y1) ;
            
            /*
            DBMS_OUTPUT.PUT_LINE('x0 ' || x0 || ' y0 ' || y0);
            DBMS_OUTPUT.PUT_LINE('x1 ' || x1 || ' y1 ' || y1);
            DBMS_OUTPUT.PUT_LINE('x2 ' || x2 || ' y2 ' || y2);
            DBMS_OUTPUT.PUT_LINE('xL ' || xL || ' yL ' || yL);
            DBMS_OUTPUT.PUT_LINE('aa ' || aa || ' bb ' || bb);
            DBMS_OUTPUT.PUT_LINE('dotproduct ' || dotproduct );
            DBMS_OUTPUT.PUT_LINE('dist ' || (POWER(x2-x1,2) + POWER(y2-y1, 2)) ); */
            dist := ( ABS( (x2 - x1)*(y1 - y0) - (x1 - x0)*(y2 - y1) ) )
                      / ( SQRT( POWER(y2 - y1, 2) + POWER(x2 - x1, 2)) );
            
            /*DBMS_OUTPUT.PUT_LINE( (ABS( aa*x0 - y0 + bb ) / ( SQRT( aa*aa + 1) ) ) ); */
            
			/*najblizszy punkt znajduje sie na prostej wyznaczanej przez odcinek AB ale jest poza granicami samego odcinka */
            IF ( dotproduct < 0 ) OR
                 dotproduct > ( POWER(x2-x1,2) + POWER(y2-y1, 2) )
            THEN
			/* w takiej sytuacji zamiast wyliczonej wczesniej odleglosci bierzemy odleglosc do pktu A lub B (pkt graniczne odcinka) - zaleznie ktory jest blizej  */
              dist := SQRT(POWER(x0 - x1,2) + POWER(y0 - y1, 2));
              if( dist > SQRT(POWER(x0 - x2,2) + POWER(y0 - y2, 2)) ) 
              then 
                dist := SQRT(POWER(x0 - x2,2) + POWER(y0 - y2, 2));
              end if;
              
            END IF;
/*DBMS_OUTPUT.PUT_LINE(dist);*/
            IF dist < smallest_dist 
            THEN 
              smallest_dist := dist;
            END IF;
      
          END LOOP;
        /*END LOOP;*/
      END LOOP;
      RETURN smallest_dist;
END;



select *
from   user_errors ur
where  ur.name = 'ODLEGLOSC_CZESC';