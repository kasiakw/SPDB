/* Wypenia tabele RIVER_GEOM i RIVER odcinkami (generuje wspolrzedne poczatka i konca odcinka) */
DECLARE
 startX NUMBER(5,2);
 startY NUMBER(5,2);
 endX NUMBER(5,2);
 endY NUMBER(5,2);
BEGIN
  dbms_random.initialize(681457888);
  FOR i IN 1 .. 50000 LOOP
    startX := ROUND(dbms_random.value(0, 200),2);
    startY := ROUND(dbms_random.value(0, 200),2);
    endX := ROUND(dbms_random.value(0, 200),2);
    endY := ROUND(dbms_random.value(0, 200),2);
    INSERT INTO RIVER
    (gid, x1, y1, x2, y2)
    VALUES
    (i, startX, startY, endX, endY);
    INSERT INTO RIVER_GEOM 
    VALUES 
    (i, MDSYS.SDO_GEOMETRY(2002, NULL,NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1),
    MDSYS.SDO_ORDINATE_ARRAY(startX, startY, endX, endY)));
  END LOOP;
  dbms_random.terminate;
  COMMIT;
END;
/