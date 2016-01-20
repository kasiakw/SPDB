SET SERVEROUTPUT ON
DECLARE
/* generowanie losowych punktów z wybranego zakresu*/
 x_coor NUMBER(5,2);
 y_coor NUMBER(5,2);
BEGIN
  dbms_random.initialize(681457777); -- I zestaw danych
  -- dbms_random.initialize(867563912); -- II zestaw danych
  FOR i IN 1 .. 50000 LOOP 
    x_coor := ROUND(dbms_random.value(0, 200),2);
    y_coor := ROUND(dbms_random.value(0, 200),2);
    INSERT INTO CITY
    (gid, x, y)
    VALUES
    (i, x_coor, y_coor);
    INSERT INTO CITY_GEOM 
    VALUES 
    (i, MDSYS.SDO_GEOMETRY(2001, NULL,
    MDSYS.SDO_POINT_TYPE(x_coor, y_coor, NULL), NULL, NULL));
  END LOOP;
  dbms_random.terminate;
  COMMIT;
END;
/