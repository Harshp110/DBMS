CREATE TABLE ACCOUNT(
  Acc_no INT PRIMARY KEY,
  branch_name VARCHAR(20),
  balance INT
);

CREATE TABLE BRANCH(
  branch_name VARCHAR(20) PRIMARY KEY,
  branch_city VARCHAR(20),
  assets INT
);
CREATE TABLE CUSTOMER(
  cust_name VARCHAR(20) PRIMARY KEY,
  cust_street VARCHAR(20),
  cust_city VARCHAR(20)
);
CREATE TABLE DEPOSITOR(
  cust_name VARCHAR(20),
  Acc_no INT,
  FOREIGN KEY (cust_name) REFERENCES CUSTOMER(cust_name),
  FOREIGN KEY (Acc_no) REFERENCES ACCOUNT(Acc_no)
);
CREATE TABLE LOAN(
  loan_no INT PRIMARY KEY,
  branch_name VARCHAR(20),
  amount INT,
  FOREIGN KEY (branch_name) REFERENCES BRANCH(branch_name)
);
CREATE TABLE BORROWER(
  cust_name VARCHAR(20),
  loan_no INT,
  FOREIGN KEY (cust_name) REFERENCES CUSTOMER(cust_name),
  FOREIGN KEY (loan_no) REFERENCES LOAN(loan_no)
);
INSERT INTO BRANCH VALUES
('Wadia College', 'Pune', 5000000),
('Camp', 'Pune', 3000000),
('MG Road', 'Mumbai', 4000000);

INSERT INTO ACCOUNT VALUES
(101, 'Wadia College', 15000),
(102, 'Camp', 12000),
(103, 'Wadia College', 20000),
(104, 'MG Road', 18000);

INSERT INTO CUSTOMER VALUES
('Harsh', 'FC Road', 'Pune'),
('Amit', 'Karve Nagar', 'Pune'),
('Priya', 'MG Road', 'Mumbai'),
('Rohit', 'Viman Nagar', 'Pune');

INSERT INTO DEPOSITOR VALUES
('Harsh', 101),
('Amit', 102),
('Priya', 103);

INSERT INTO LOAN VALUES
(201, 'Wadia College', 13000),
(202, 'Camp', 10000),
(203, 'Wadia College', 25000);

INSERT INTO BORROWER VALUES
('Harsh', 201),
('Rohit', 203);


SELECT DISTINCT C.cust_name
FROM CUSTOMER C
JOIN DEPOSITOR D ON C.cust_name = D.cust_name
JOIN BORROWER B ON C.cust_name = B.cust_name;

SELECT cust_name FROM DEPOSITOR
UNION
SELECT cust_name FROM BORROWER;

SELECT DISTINCT D.cust_name
FROM DEPOSITOR D
WHERE D.cust_name NOT IN (SELECT cust_name FROM BORROWER);

SELECT AVG(balance) AS AvgBalance
FROM ACCOUNT
WHERE branch_name = 'Wadia College';

SELECT A.branch_name, COUNT(D.cust_name) AS NoOfDepositors
FROM DEPOSITOR D
JOIN ACCOUNT A ON D.Acc_no = A.Acc_no
GROUP BY A.branch_name;





