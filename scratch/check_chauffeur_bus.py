import sqlite3
conn = sqlite3.connect('smart_trans.db')
conn.row_factory = sqlite3.Row
cursor = conn.cursor()
cursor.execute("SELECT * FROM Bus WHERE Code_chauffeur = 5")
rows = cursor.fetchall()
for row in rows:
    print(dict(row))
conn.close()
