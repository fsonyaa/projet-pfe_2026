import sqlite3

def setup_parcours():
    # تأكدي إن الداتابيز في الدوسي الرئيسي v2
    conn = sqlite3.connect('smart_trans.db') 
    cursor = conn.cursor()

    # 1. نحيو القديم باش ما يعملناش مشاكل أسامي
    cursor.execute("DROP TABLE IF EXISTS Parcours")

    # 2. صنع الجدول حسب الـ Structure متاعك
    cursor.execute('''
        CREATE TABLE Parcours (
            ID_parcours INTEGER PRIMARY KEY AUTOINCREMENT,
            Depart TEXT,
            Arrivee TEXT,
            Heure_depart TEXT,
            Heure_arrivee TEXT,
            Code_Ligne INTEGER,
            FOREIGN KEY (Code_Ligne) REFERENCES Ligne (Code_Ligne)
        )
    ''')

    # 3. صب بيانات قابس (تبلّبو والازدهار) حسب الـ Structure الجديدة
    # (Depart, Arrivee, Heure_depart, Heure_arrivee, Code_Ligne)
    data = [
        ("Tbelbo", "Izdehar", "06:30", "07:15", 1),
        ("Izdehar", "Tbelbo", "07:30", "08:15", 1),
        ("Tbelbo", "Izdehar", "07:20", "08:10", 6),
        ("Izdehar", "Tbelbo", "08:30", "09:20", 6)
    ]

    try:
        cursor.executemany('''
            INSERT INTO Parcours (Depart, Arrivee, Heure_depart, Heure_arrivee, Code_Ligne) 
            VALUES (?, ?, ?, ?, ?)
        ''', data)
        conn.commit()
        print("✅ Mabrouk! Le tableau Parcours est maintenant conforme à ta structure.")
    except Exception as e:
        print(f"❌ Erreur: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    setup_parcours()