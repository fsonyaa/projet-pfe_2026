import sqlite3

def check_incidents():
    conn = sqlite3.connect('smart_trans.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    print("--- INCIDENTS ---")
    cursor.execute("SELECT * FROM Incident")
    rows = cursor.fetchall()
    for row in rows:
        print(dict(row))
        
    print("\n--- BUSES ---")
    cursor.execute("SELECT * FROM Bus")
    rows = cursor.fetchall()
    for row in rows:
        print(dict(row))
        
    conn.close()

if __name__ == "__main__":
    check_incidents()
