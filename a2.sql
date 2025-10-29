CREATE TABLE Branch (
  branch_name VARCHAR(50) PRIMARY KEY,
  branch_city VARCHAR(50) NOT NULL,
  assets DECIMAL(12,2) CHECK (assets >= 0)
);

CREATE TABLE Account (
  acc_no INT PRIMARY KEY,
  branch_name VARCHAR(50),  -- changed from 20 → 50
  balance DECIMAL(12,2),
  FOREIGN KEY (branch_name) REFERENCES Branch(branch_name)
);

CREATE TABLE Customer (
  cust_name VARCHAR(50) PRIMARY KEY,
  cust_street VARCHAR(50),
  cust_city VARCHAR(50)
);

CREATE TABLE Depositor (
  cust_name VARCHAR(50),
  acc_no INT,
  FOREIGN KEY (cust_name) REFERENCES Customer(cust_name),
  FOREIGN KEY (acc_no) REFERENCES Account(acc_no)
);

CREATE TABLE Loan (
  loan_no INT PRIMARY KEY,
  branch_name VARCHAR(50),  -- changed from 20 → 50
  amount DECIMAL(12,2),
  FOREIGN KEY (branch_name) REFERENCES Branch(branch_name)
);

CREATE TABLE Borrower (
  cust_name VARCHAR(50),
  loan_no INT,
  FOREIGN KEY (cust_name) REFERENCES Customer(cust_name),
  FOREIGN KEY (loan_no) REFERENCES Loan(loan_no)
);



SELECT DISTINCT branch_name
FROM LOAN;


SELECT loan_no
FROM Loan
WHERE branch_name = 'Akurdi'
  AND amount > 12000;
  
  
SELECT B.cust_name, L.loan_no, L.amount
FROM Borrower B
JOIN Loan L ON B.loan_no = L.loan_no;

SELECT DISTINCT B.cust_name
FROM Borrower B
JOIN Loan L ON B.loan_no = L.loan_no
WHERE L.branch_name = 'Akurdi'
ORDER BY B.cust_name ASC;


SELECT cust_name
FROM Depositor
UNION
SELECT cust_name
FROM Borrower;


SELECT DISTINCT D.cust_name
FROM Depositor D
JOIN Borrower B ON D.cust_name = B.cust_name;

SELECT DISTINCT D.cust_name
FROM Depositor D
WHERE D.cust_name NOT IN (SELECT cust_name FROM Borrower);



SELECT branch_name, AVG(balance) AS avg_balance
FROM Account
GROUP BY branch_name;


SELECT A.branch_name, COUNT(DISTINCT D.cust_name) AS num_depositors
FROM Account A
JOIN Depositor D ON A.acc_no = D.acc_no
GROUP BY A.branch_name;


SELECT cust_name, cust_city
FROM Customer
WHERE cust_name LIKE 'P%';


SELECT DISTINCT branch_city
FROM Branch;


SELECT branch_name
FROM Account
GROUP BY branch_name
HAVING AVG(balance) > 12000;



SELECT COUNT(*) AS total_customers
FROM Customer;


SELECT SUM(amount) AS total_loan_amount
FROM Loan;


DELETE FROM Loan
WHERE amount BETWEEN 1300 AND 1500;


DELETE FROM Branch
WHERE branch_city = 'Nigdi';









