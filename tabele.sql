CREATE TABLE COUNTRY_GEOM (
  gid NUMBER(5) PRIMARY KEY,
  geom SDO_GEOMETRY);
  
CREATE TABLE RIVER_GEOM (
  gid NUMBER(5) PRIMARY KEY,
  line SDO_GEOMETRY);
  
CREATE TABLE CITY_GEOM (
  gid NUMBER(5) PRIMARY KEY,
  point SDO_GEOMETRY);
  
CREATE TABLE COUNTRY(
  gid NUMBER PRIMARY KEY,
  geom_nr NUMBER(5),  /* okresla wielokat do kt�rego nalezy punkt */
  point_nr NUMBER(2), /* okresla kolejnosc wierzcholkow w wielokacie (liczac od 1) */
  x NUMBER(5,2),
  y NUMBER(5,2));

/* odcinek (x1, y1) - pocz�tek, (x2, y2) - koniec */  
CREATE TABLE RIVER(
  gid NUMBER PRIMARY KEY,
  x1 NUMBER(5,2),
  y1 NUMBER(5,2),
  x2 NUMBER(5,2),
  y2 NUMBER(5,2));
  
CREATE TABLE CITY(
  gid NUMBER PRIMARY KEY,
  x NUMBER(5,2),
  y NUMBER(5,2));

/* Assume that two dimensions are named X and Y, their bounds are 0 to 300, and tolerance for both dimensions is 0.05. */  
INSERT INTO USER_SDO_GEOM_METADATA
  VALUES ('COUNTRY_GEOM', 'GEOM', 
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 0, 300, 0.05),
                      MDSYS.SDO_DIM_ELEMENT('Y', 0, 300, 0.05)), NULL);
  
INSERT INTO USER_SDO_GEOM_METADATA VALUES ('RIVER_GEOM', 'LINE', 
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 0, 300, 0.05),
                      MDSYS.SDO_DIM_ELEMENT('Y', 0, 300, 0.05)), NULL);
  
INSERT INTO USER_SDO_GEOM_METADATA VALUES ('CITY_GEOM', 'POINT', 
  MDSYS.SDO_DIM_ARRAY(MDSYS.SDO_DIM_ELEMENT('X', 0, 300, 0.05),
                      MDSYS.SDO_DIM_ELEMENT('Y', 0, 300, 0.05)), NULL);
                      
/* Tworzenie R-tree indeks�w przestrzennych (wymagane do zapyta�)*/
CREATE INDEX country_geom_idx
   ON country_geom(geom)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;
   
CREATE INDEX river_geom_idx
   ON river_geom(line)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;
   
CREATE INDEX city_geom_idx
   ON city_geom(point)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;

CREATE INDEX country_geom_nr_idx ON country(geom_nr);
-- Po du�ym insercie nale�y przebudowa� indeks
ALTER INDEX country_geom_nr_idx REBUILD;
ALTER INDEX country_geom_idx REBUILD;
ALTER INDEX river_geom_idx REBUILD;
ALTER INDEX city_geom_idx REBUILD;

/* Po du�ym insercie dobrze jest te� uaktualni� statystyki */
EXEC DBMS_STATS.gather_table_stats('SYSTEM', 'COUNTRY_GEOM');
EXEC DBMS_STATS.gather_table_stats('SYSTEM', 'RIVER_GEOM');
EXEC DBMS_STATS.gather_table_stats('SYSTEM', 'CITY_GEOM');
EXEC DBMS_STATS.gather_table_stats('SYSTEM', 'COUNTRY');
EXEC DBMS_STATS.gather_table_stats('SYSTEM', 'RIVER');
EXEC DBMS_STATS.gather_table_stats('SYSTEM', 'CITY');

/* aby zobaczyc explain plan dla wybranego zapytania */ 
explain plan for 
SELECT geom_nr
FROM country
WHERE zawiera_punkt(geom_nr, 10) = 1
GROUP BY geom_nr;

select * from table(dbms_xplan.display);

/*truncate table COUNTRY_GEOM;
truncate table COUNTRY;
truncate table RIVER_GEOM;
truncate table RIVER;
truncate table CITY_GEOM;
truncate table CITY;
drop index country_geom_nr_idx;
select * from USER_SDO_GEOM_METADATA;*/







