import sqlite3

def check_incidents():
    conn = sqlite3.connect('smart_trans.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    print("--- LAST 5 INCIDENTS ---")
    rows = cursor.execute("SELECT * FROM Incident ORDER BY ID_incident DESC LIMIT 5").fetchall()
    for row in rows:
        print(dict(row))
        
    print("\n--- LAST 5 PARCOURS ---")
    rows = cursor.execute("SELECT * FROM Parcours ORDER BY ID_parcours DESC LIMIT 5").fetchall()
    for row in rows:
        print(dict(row))
        
    print("\n--- LAST 5 HISTORIQUE ---")
    rows = cursor.execute("SELECT * FROM Historique ORDER BY ID_historique DESC LIMIT 5").fetchall()
    for row in rows:
        print(dict(row))

    conn.close()

if __name__ == "__main__":
    check_incidents()
