import sqlite3

def repair_incidents():
    conn = sqlite3.connect('smart_trans.db')
    cursor = conn.cursor()
    
    # 1. Update incidents where Code_Ligne is NULL but we have a Code_chauffeur
    # We'll try to find the last Parcours/Ligne for that chauffeur
    cursor.execute("""
        UPDATE Incident 
        SET Code_Ligne = (
            SELECT P.Code_Ligne 
            FROM Historique H
            JOIN Parcours P ON H.ID_parcours = P.ID_parcours
            WHERE H.Code_chauffeur = Incident.Code_chauffeur
            ORDER BY H.ID_historique DESC LIMIT 1
        )
        WHERE Code_Ligne IS NULL AND Code_chauffeur IS NOT NULL
    """)
    
    print(f"Repaired {cursor.rowcount} incidents.")
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    repair_incidents()
