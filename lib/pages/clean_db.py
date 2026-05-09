import sqlite3

def clean_historique():
    try:
        # حل الداتابيز
        conn = sqlite3.connect('smart_trans.db')
        cursor = conn.cursor()
        
        # فسخ كل شيء في جدول Historique
        cursor.execute("DELETE FROM Historique")
        
        # تصفير الـ ID باش يبدا مالـ 1 من جديد (اختياري)
        cursor.execute("DELETE FROM sqlite_sequence WHERE name='Historique'")
        
        conn.commit()
        conn.close()
        print("✅ الجدول تنظّف مريغل والـ IDs رجعوا مالصفر!")
    except Exception as e:
        print(f"❌ صار غلط: {e}")

if __name__ == "__main__":
    clean_historique()