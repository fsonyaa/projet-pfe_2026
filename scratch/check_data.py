import sqlite3
conn = sqlite3.connect('smart_trans.db')
conn.row_factory = sqlite3.Row
cursor = conn.cursor()
cursor.execute("SELECT * FROM Incident WHERE Description LIKE '[IA ALERT]%'")
rows = cursor.fetchall()
for row in rows:
    print(dict(row))
conn.close()
