CREATE TABLE O_RollCall (
  RollNo NUMBER PRIMARY KEY,
  Name   VARCHAR2(50)
);

CREATE TABLE N_RollCall (
  RollNo NUMBER,
  Name   VARCHAR2(50)
);
INSERT INTO O_RollCall VALUES (101, 'Harsh');
INSERT INTO O_RollCall VALUES (102, 'Aman');
INSERT INTO O_RollCall VALUES (103, 'Riya');
INSERT INTO N_RollCall VALUES (102, 'Aman');
INSERT INTO N_RollCall VALUES (104, 'Sneha');
INSERT INTO N_RollCall VALUES (105, 'Raj');
COMMIT;
SET SERVEROUTPUT ON;

DECLARE
  -- Cursor to fetch all rows from N_RollCall
  CURSOR c_new IS
    SELECT RollNo, Name FROM N_RollCall;

  -- Variables to hold each row's data temporarily
  v_rollno N_RollCall.RollNo%TYPE;
  v_name   N_RollCall.Name%TYPE;

  -- To check if roll number already exists
  v_count NUMBER;
BEGIN
  -- Open cursor and loop through each record
  FOR rec IN c_new LOOP
    -- Check if that RollNo already exists in O_RollCall
    SELECT COUNT(*) INTO v_count
    FROM O_RollCall
    WHERE RollNo = rec.RollNo;

    IF v_count = 0 THEN
      -- Not found → Insert the new record
      INSERT INTO O_RollCall (RollNo, Name)
      VALUES (rec.RollNo, rec.Name);

      DBMS_OUTPUT.PUT_LINE('Inserted: RollNo = ' || rec.RollNo || ', Name = ' || rec.Name);
    ELSE
      -- Found → Skip
      DBMS_OUTPUT.PUT_LINE('Skipped (already exists): RollNo = ' || rec.RollNo);
    END IF;
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Merge completed successfully.');
END;
/
