/* count area with shoelace formula */
CREATE OR REPLACE FUNCTION odleglosc (g1_nr IN NUMBER, g2_nr IN NUMBER)
  return number
  IS 
  firstside NUMBER(10,2);
  secondside NUMBER(10,2);
  
  dist NUMBER(8,2);
  BEGIN
    firstside := odleglosc_czesc(g1_nr, g2_nr);
    secondside := odleglosc_czesc(g2_nr, g1_nr);
    
    /*DBMS_OUTPUT.PUT_LINE('firstside ' ||  firstside);
    DBMS_OUTPUT.PUT_LINE('secondside ' ||  secondside);*/
    
    IF firstside > secondside then dist := secondside; else dist := firstside; end if;
    RETURN dist;
END;
    


select *
from   user_errors ur
where  ur.name = 'ODLEGLOSC';
