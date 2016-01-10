/*DROP TABLE COUNTRY_GEOM;
DROP TABLE RIVER_GEOM;
DROP TABLE CITY_GEOM;
DROP TABLE COUNTRY;
DROP TABLE RIVER;
DROP TABLE CITY;*/

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

/*truncate table COUNTRY_GEOM;
truncate table COUNTRY;
truncate table RIVER_GEOM;
truncate table RIVER;
truncate table CITY_GEOM;
truncate table CITY;
select geom from COUNTRY_GEOM;
select * from COUNTRY;
select * from CITY;
select * from CITY_GEOM;
select * from RIVER;
select * from RIVER_GEOM;
select * from USER_SDO_GEOM_METADATA;*/

