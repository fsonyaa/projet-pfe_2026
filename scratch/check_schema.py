import sqlite3
conn = sqlite3.connect('smart_trans.db')
cursor = conn.cursor()
cursor.execute("PRAGMA table_info(Incident)")
columns = cursor.fetchall()
for col in columns:
    print(col)
conn.close()
