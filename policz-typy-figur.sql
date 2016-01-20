select count(t.gid), v from 
( select c1.gid, SDO_UTIL.GETNUMVERTICES(c1.geom) v
  from country_geom c1 ) t
group by v;