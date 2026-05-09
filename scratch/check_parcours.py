import sqlite3

def check_parcours():
    conn = sqlite3.connect('smart_trans.db')
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    print("--- PARCOURS 59 ---")
    row = cursor.execute("SELECT * FROM Parcours WHERE ID_parcours = 59").fetchone()
    if row:
        print(dict(row))
    else:
        print("Not found")

    print("\n--- ALL PARCOURS IDS ---")
    rows = cursor.execute("SELECT ID_parcours, Code_Ligne FROM Parcours").fetchall()
    for row in rows:
        print(dict(row))

    conn.close()

if __name__ == "__main__":
    check_parcours()
