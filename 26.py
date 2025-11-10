# Install MySQL Server (Debian/Ubuntu)
sudo apt update && sudo apt install -y mysql-server

# Start and secure MySQL
sudo systemctl enable --now mysql
sudo mysql_secure_installation

# Create a user (example) and DB from MySQL shell
sudo mysql -e "CREATE DATABASE IF NOT EXISTS demo_db;
CREATE USER IF NOT EXISTS 'demo'@'localhost' IDENTIFIED BY 'demo_pass';
GRANT ALL PRIVILEGES ON demo_db.* TO 'demo'@'localhost';
FLUSH PRIVILEGES;"

python -m pip install -U mysql-connector-python

#Program
import os
import sys
from getpass import getpass
import mysql.connector
from mysql.connector import Error

DB_NAME = os.getenv("MYSQL_DB", "demo_db")
DB_HOST = os.getenv("MYSQL_HOST", "localhost")
DB_USER = os.getenv("MYSQL_USER", "demo")
DB_PASS = os.getenv("MYSQL_PASS", "demo_pass")

TABLE_SQL = """
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(150) UNIQUE NOT NULL,
    department VARCHAR(100) NOT NULL,
    salary     DECIMAL(10,2) NOT NULL
)
"""

def connect(db=DB_NAME):
    try:
        # Ensure DB exists (connect to server first)
        base = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS)
        with base.cursor() as c:
            c.execute(f"CREATE DATABASE IF NOT EXISTS {db}")
        base.close()

        conn = mysql.connector.connect(
            host=DB_HOST, user=DB_USER, password=DB_PASS, database=db
        )
        with conn.cursor() as c:
            c.execute(TABLE_SQL)
        conn.commit()
        return conn
    except Error as e:
        sys.exit(f"DB connect/init failed: {e}\n"
                 "Tip: pip install -U mysql-connector-python and check credentials.")

def add_employee(conn):
    fn = input("First name: ").strip()
    ln = input("Last name: ").strip()
    em = input("Email: ").strip()
    dept = input("Department: ").strip()
    try:
        sal = float(input("Salary: ").strip())
    except ValueError:
        print("Invalid salary"); return
    sql = """INSERT INTO employees(first_name,last_name,email,department,salary)
             VALUES (%s,%s,%s,%s,%s)"""
    try:
        with conn.cursor() as c:
            c.execute(sql, (fn, ln, em, dept, sal))
        conn.commit()
        print("Added.")
    except Error as e:
        print(f"Add failed: {e}")

def list_employees(conn, where=None, params=()):
    sql = "SELECT id, first_name, last_name, email, department, salary FROM employees"
    if where:
        sql += f" WHERE {where}"
    try:
        with conn.cursor() as c:
            c.execute(sql, params)
            rows = c.fetchall()
        if not rows:
            print("(no rows)")
        else:
            for r in rows:
                print(f"[{r[0]}] {r[1]} {r[2]} | {r[3]} | {r[4]} | ₹{r[5]}")
    except Error as e:
        print(f"Read failed: {e}")

def update_employee(conn):
    try:
        emp_id = int(input("Employee ID to update: ").strip())
    except ValueError:
        print("Invalid ID"); return

    fields = []
    values = []
    print("Leave blank to skip a field.")
    fn = input("New first name: ").strip()
    ln = input("New last name: ").strip()
    em = input("New email: ").strip()
    dept = input("New department: ").strip()
    sal = input("New salary: ").strip()

    if fn:  fields.append("first_name=%s"); values.append(fn)
    if ln:  fields.append("last_name=%s");  values.append(ln)
    if em:  fields.append("email=%s");      values.append(em)
    if dept:fields.append("department=%s"); values.append(dept)
    if sal:
        try:
            values.append(float(sal))
            fields.append("salary=%s")
        except ValueError:
            print("Invalid salary"); return

    if not fields:
        print("Nothing to update."); return

    sql = f"UPDATE employees SET {', '.join(fields)} WHERE id=%s"
    values.append(emp_id)
    try:
        with conn.cursor() as c:
            c.execute(sql, tuple(values))
        conn.commit()
        print(f"Updated ({c.rowcount} row).")
    except Error as e:
        print(f"Update failed: {e}")

def delete_employee(conn):
    try:
        emp_id = int(input("Employee ID to delete: ").strip())
    except ValueError:
        print("Invalid ID"); return
    try:
        with conn.cursor() as c:
            c.execute("DELETE FROM employees WHERE id=%s", (emp_id,))
        conn.commit()
        print(f"Deleted ({c.rowcount} row).")
    except Error as e:
        print(f"Delete failed: {e}")

def menu():
    print("""
[1] Add
[2] List all
[3] Search by department
[4] Edit (update)
[5] Delete
[0] Exit
""")

def main():
    # Allow quick override of creds via args: host user (password prompt) db
    global DB_HOST, DB_USER, DB_PASS, DB_NAME
    if len(sys.argv) >= 3:
        DB_HOST = sys.argv[1]
        DB_USER = sys.argv[2]
        DB_PASS = getpass("Password: ")
        DB_NAME = sys.argv[3] if len(sys.argv) >= 4 else DB_NAME

    conn = connect()
    try:
        while True:
            menu()
            ch = input("Select: ").strip()
            if ch == "1": add_employee(conn)
            elif ch == "2": list_employees(conn)
            elif ch == "3":
                d = input("Department: ").strip()
                list_employees(conn, "department=%s", (d,))
            elif ch == "4": update_employee(conn)
            elif ch == "5": delete_employee(conn)
            elif ch == "0": break
            else: print("Invalid choice")
    finally:
        if conn.is_connected():
            conn.close()
            print("Connection closed.")

if __name__ == "__main__":
    main()
