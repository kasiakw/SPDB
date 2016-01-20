SET SERVEROUTPUT ON
DECLARE
/* wielokat jest budowany na elipsie o srodku (x, y) i promieniach rx i ry */
/* liczba wierzcholkow wielokata 3,4 lub 5 */
 x0 NUMBER(5,2);
 y0 NUMBER(5,2);
 rx NUMBER(5,2);
 ry NUMBER(5,2);
 n NUMBER(2); 
 country_id NUMBER;
 coord_array MDSYS.SDO_ORDINATE_ARRAY := MDSYS.SDO_ORDINATE_ARRAY();
 x_coor NUMBER(5,2);
 y_coor NUMBER(5,2);
 k NUMBER;
 ind NUMBER(3);
 pi NUMBER := 3.14159265359;
BEGIN
  dbms_random.initialize(681457802); -- I zestaw danych
  -- dbms_random.initialize(867234567); -- II zestaw danych
  country_id := 0;
  FOR i IN 1 .. 10 LOOP
    n := 0; -- liczba wierzcholkow 
    x0 := ROUND(dbms_random.value(100, 200),2);
    y0 := ROUND(dbms_random.value(100, 200),2);
    rx := ROUND(dbms_random.value(10, 50),2);
    ry := ROUND(dbms_random.value(10, 50),2);
    k := 0;
    ind := 0;
    coord_array.Delete();
    /* generowanie wierzcholkow wielokata po elipsie */
    WHILE k < 2.0*pi LOOP
      n := n + 1;
      country_id := country_id +1;
      /* funkcje COS/SIN przyjmuja wartosci w radianach */
      x_coor := x0 + (rx * COS(k));
      y_coor := y0 + (ry * SIN(k));
      coord_array.Extend(2);
      coord_array(ind+1) := x_coor;
      coord_array(ind+2) := y_coor;
      ind := ind + 2;
      -- DBMS_OUTPUT.put_line('i=' || i || ' : value=' || DBMS_RANDOM.value(0, 1) || ' k=' || k);
      /* losowy skok o <55; 150) stopni */
      k := k + (55.0 + 95.0*dbms_random.value(0, 1)) * pi/180;
      EXIT WHEN n > 5; --jesli wiecej niz 5 wierzcholkow
      INSERT INTO COUNTRY
      (gid, geom_nr, x, y)
      VALUES
      (country_id, i, x_coor, y_coor);
    END LOOP;
    IF n < 3 THEN
      DBMS_OUTPUT.PUT_LINE('ZA MALA LICZBA WIERZCHOLKOW');
      execute immediate 'truncate table COUNTRY_GEOM';
      execute immediate 'truncate table COUNTRY';
      RETURN;
    END IF;
    /* pierwszy punkt to te¿ ostatni dla wielokata w SDO_GEOMETRY */
    coord_array.Extend(2);
    coord_array(ind+1) := coord_array(1);
    coord_array(ind+2) := coord_array(2);
    INSERT INTO COUNTRY_GEOM 
    VALUES 
    (i, MDSYS.SDO_GEOMETRY(2003, NULL,NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
    coord_array));
  END LOOP;
  dbms_random.terminate;
  COMMIT;
END;
/