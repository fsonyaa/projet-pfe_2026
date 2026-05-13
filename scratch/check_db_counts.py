import sqlite3

def check_db():
    try:
        conn = sqlite3.connect('smart_trans.db')
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        # List tables
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = [row[0] for row in cursor.fetchall()]
        print(f"Tables: {tables}")
        
        # Check counts for main tables
        for table in tables:
            if table == 'sqlite_sequence': continue
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"Table {table}: {count} rows")
            
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    check_db()
