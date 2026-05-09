import sqlite3

def check():
    conn = sqlite3.connect('database_khawla.db')
    cursor = conn.cursor()
    
    # يخرج أسامي الجداول الكل
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    print("--- الجداول الموجودة في الداتابيز ---")
    for t in tables:
        print(f"✅ Table: {t[0]}")
    
    conn.close()

if __name__ == "__main__":
    check()