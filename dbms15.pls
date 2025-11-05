CREATE TABLE areas (
  radius NUMBER,
  area   NUMBER
);

SET SERVEROUTPUT ON;

DECLARE
v_radius NUMBER;
v_area NUMBER;
v_pi CONSTANT NUMBER := 3.1415;

BEGIN
FOR v_radius IN 5..9 LOOP
v_area := v_pi * v_radius * v_radius;
INSERT INTO areas (radius, area)
VALUES (v_radius, v_area);
DBMS_OUTPUT.PUT_Line('Radius: ' || v_radius || ' | Area: ' || v_area);
END LOOP;
DBMS_OUTPUT.PUT_Line('All values inserted successfully!');
END;
/