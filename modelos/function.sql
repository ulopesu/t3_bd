-- function signature (PostgreSQL 10)
CREATE OR REPLACE FUNCTION "testeScheduleSerial" () 
RETURNS integer AS $$
  BEGIN
    RETURN 1;
  END;
$$ LANGUAGE plpgsql;

-- calling function
SELECT "testeScheduleSerial"() AS resp;
