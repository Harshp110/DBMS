# 1) Install/start MongoDB (Ubuntu/Debian example)
sudo apt update
sudo apt install -y mongodb
sudo systemctl enable --now mongodb   # service name may be 'mongod' on some distros

# 2) Python driver
python -m pip install -U pymongo

#Program to perform CRUD operations in MongoDB
import os
import sys
from getpass import getpass
from bson import ObjectId
from pymongo import MongoClient, errors

DEFAULT_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
DB_NAME = os.getenv("MONGO_DB", "demo_db")
COLL_NAME = os.getenv("MONGO_COLL", "employees")

def connect(uri=DEFAULT_URI, db_name=DB_NAME, coll_name=COLL_NAME):
    """
    Connect to MongoDB and return (client, db, collection).
    Fails fast with a clear message if not reachable.
    """
    client = MongoClient(uri, serverSelectionTimeoutMS=5000)
    try:
        client.admin.command("ping")
        print(f"Connected: {uri}")
    except errors.ServerSelectionTimeoutError as e:
        sys.exit(f"Cannot connect to MongoDB: {e}\n"
                 f"Tip: ensure the service is running (e.g., `sudo systemctl status mongod`/`mongodb`).")
    db = client[db_name]
    coll = db[coll_name]
    # helpful unique index on email (ignore if already exists)
    try:
        coll.create_index("email", unique=True)
    except Exception:
        pass
    return client, db, coll

def prompt_float(label):
    while True:
        s = input(label).strip()
        try:
            return float(s)
        except ValueError:
            print("Enter a valid number.")

def add_employee(coll):
    doc = {
        "first_name": input("First name: ").strip(),
        "last_name":  input("Last name: ").strip(),
        "email":      input("Email: ").strip(),
        "department": input("Department: ").strip(),
        "salary":     prompt_float("Salary: "),
    }
    try:
        res = coll.insert_one(doc)
        print(f"Added with _id: {res.inserted_id}")
    except errors.DuplicateKeyError:
        print("Email already exists (unique).")
    except Exception as e:
        print(f"Add failed: {e}")

def list_employees(coll, query=None):
    query = query or {}
    try:
        rows = list(coll.find(query))
        if not rows:
            print("(no documents)")
            return
        for r in rows:
            print(f"[{r.get('_id')}] {r.get('first_name','')} {r.get('last_name','')} | "
                  f"{r.get('email','')} | {r.get('department','')} | ₹{r.get('salary')}")
    except Exception as e:
        print(f"Read failed: {e}")

def update_employee(coll):
    _id = input("Employee _id to update: ").strip()
    try:
        oid = ObjectId(_id)
    except Exception:
        print("Invalid _id"); return

    # collect updates (only set what user provides)
    updates = {}
    print("Leave blank to skip a field.")
    fn = input("New first name: ").strip()
    ln = input("New last name: ").strip()
    em = input("New email: ").strip()
    dp = input("New department: ").strip()
    sl = input("New salary: ").strip()

    if fn: updates["first_name"] = fn
    if ln: updates["last_name"]  = ln
    if em: updates["email"]      = em
    if dp: updates["department"] = dp
    if sl:
        try:
            updates["salary"] = float(sl)
        except ValueError:
            print("Invalid salary"); return

    if not updates:
        print("Nothing to update.")
        return

    try:
        res = coll.update_one({"_id": oid}, {"$set": updates})
        if res.matched_count == 0:
            print("No document with that _id.")
        else:
            print(f"Updated ({res.modified_count} doc).")
    except errors.DuplicateKeyError:
        print("Email already exists (unique).")
    except Exception as e:
        print(f"Update failed: {e}")

def delete_employee(coll):
    _id = input("Employee _id to delete: ").strip()
    try:
        oid = ObjectId(_id)
    except Exception:
        print("Invalid _id"); return

    try:
        res = coll.delete_one({"_id": oid})
        if res.deleted_count:
            print("Deleted.")
        else:
            print("No document with that _id.")
    except Exception as e:
        print(f"Delete failed: {e}")

def seed_demo(coll):
    """Optional: add a couple of demo docs."""
    try:
        coll.insert_many([
            {"first_name":"Rahul","last_name":"Sharma","email":"rahul@example.com","department":"IT","salary":75000},
            {"first_name":"Priya","last_name":"Patel","email":"priya@example.com","department":"HR","salary":65000},
        ], ordered=False)
    except errors.BulkWriteError:
        pass

def menu():
    print("""
[1] Add employee
[2] List all
[3] Search by department
[4] Update (by _id)
[5] Delete (by _id)
[6] Seed demo data
[0] Exit
""")

def main():
    # Allow quick URI override via CLI: python mongo_crud.py <uri>
    uri = sys.argv[1] if len(sys.argv) >= 2 else DEFAULT_URI
    client, db, coll = connect(uri)

    try:
        while True:
            menu()
            ch = input("Select: ").strip()
            if   ch == "1": add_employee(coll)
            elif ch == "2": list_employees(coll)
            elif ch == "3":
                d = input("Department: ").strip()
                list_employees(coll, {"department": d})
            elif ch == "4": update_employee(coll)
            elif ch == "5": delete_employee(coll)
            elif ch == "6": seed_demo(coll)
            elif ch == "0": break
            else: print("Invalid choice")
    finally:
        client.close()
        print("Connection closed.")

if __name__ == "__main__":
    main()
