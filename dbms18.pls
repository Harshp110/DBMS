CREATE TABLE Stud (
  Roll NUMBER PRIMARY KEY,
  Name VARCHAR2(50),
  Attendance NUMBER(5,2),
  Status VARCHAR2(20)
);

INSERT INTO Stud VALUES (101, 'Harsh', 82, NULL);
INSERT INTO Stud VALUES (102, 'Aman', 65, NULL);
INSERT INTO Stud VALUES (103, 'Riya', 75, NULL);
COMMIT;
SET SERVEROUTPUT ON;

DECLARE
  v_roll Stud.Roll%TYPE := &Roll;           -- User input for roll number
  v_attendance Stud.Attendance%TYPE;        -- To store fetched attendance
BEGIN
  -- Fetch the attendance for given roll number
  SELECT Attendance INTO v_attendance
  FROM Stud
  WHERE Roll = v_roll;

  -- Compare attendance and act accordingly
  IF v_attendance < 75 THEN
    UPDATE Stud
    SET Status = 'Detained'
    WHERE Roll = v_roll;

    DBMS_OUTPUT.PUT_LINE('Term not granted.');
  ELSE
    UPDATE Stud
    SET Status = 'Not Detained'
    WHERE Roll = v_roll;

    DBMS_OUTPUT.PUT_LINE('Term granted.');
  END IF;

  COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No student found with the entered roll number.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/
