CREATE TABLE Borrower(
ROll_no NUMBER PRIMARY KEY,
Name VARCHAR2(50),
Date_of_Issue DATE,
Name_of_Book VARCHAR2(50),
Status CHAR(1)
);

CREATE TABLE Fine (
  Roll_no NUMBER,
  Date_of_Return DATE,
  Amt NUMBER(10,2)
);

INSERT INTO Borrower VALUES (1, 'Rohan', TO_DATE('2025-09-01','YYYY-MM-DD'), 'DBMS Concepts', 'I');


DECLARE
  v_roll Borrower.Roll_no%TYPE;  -- Variable for Roll number
  v_book Borrower.Name_of_Book%TYPE;  -- Variable for Book name
  v_date_issue Borrower.Date_of_Issue%TYPE;  -- Variable for date of issue
  v_days NUMBER;  -- Number of days book kept
  v_fine NUMBER := 0;  -- Fine amount
  v_status Borrower.Status%TYPE;  -- To store current status (I/R)
  fine_excep EXCEPTION;  -- User-defined exception

BEGIN
  v_roll := &Roll_no;     -- Ask user for roll number
  v_book := '&BookName';  -- Ask user for book name

  SELECT Date_of_Issue, Status INTO v_date_issue, v_status
  FROM Borrower
  WHERE Roll_no = v_roll AND Name_of_Book = v_book;

  IF v_status = 'R' THEN
    RAISE fine_excep;  -- Book already returned → throw custom error
  END IF;
  v_days := SYSDATE - v_date_issue;
    IF v_days BETWEEN 15 AND 30 THEN
    v_fine := (v_days - 14) * 5;
  ELSIF v_days > 30 THEN
    v_fine := (16 * 5) + ((v_days - 30) * 50);
  ELSE
    v_fine := 0;
  END IF;
  UPDATE Borrower SET Status = 'R' WHERE Roll_no = v_roll;

  IF v_fine > 0 THEN
    INSERT INTO Fine VALUES (v_roll, SYSDATE, v_fine);
  END IF;
  DBMS_OUTPUT.PUT_LINE('Book Returned Successfully!');
  DBMS_OUTPUT.PUT_LINE('Fine Amount = Rs ' || v_fine);
EXCEPTION
  WHEN fine_excep THEN
    DBMS_OUTPUT.PUT_LINE('Error: Book already returned.');
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: No record found for given Roll No. and Book.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected Error: ' || SQLERRM);
END;
/
