SELECT unique c.geom_nr, system.odleglosc(1, geom_nr)
    FROM country c
    where system.odleglosc(1, geom_nr) < 10
;