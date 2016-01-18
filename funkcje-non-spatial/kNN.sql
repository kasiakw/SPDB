select *
  from  
  ( SELECT unique c.geom_nr, system.odleglosc(1, geom_nr)
    FROM country c
    where geom_nr != 1 
    order by system.odleglosc(1, geom_nr) asc) 
 where ROWNUM <= 5;