import sqlite3
conn = sqlite3.connect('smart_trans.db')
conn.row_factory = sqlite3.Row
cursor = conn.cursor()
cursor.execute("SELECT * FROM Bus WHERE Code_bus = 6")
row = cursor.fetchone()
if row:
    print(dict(row))
else:
    print("No bus found with Code_bus = 6")
conn.close()
