import sqlite3

def fix_null_parcours():
    try:
        conn = sqlite3.connect('smart_trans.db')
        cursor = conn.cursor()
        
        print("Mise à jour des avis avec ID_parcours manquant...")
        
        # Mettre à jour ID_parcours à partir de l'historique
        cursor.execute("""
            UPDATE Avis 
            SET ID_parcours = (
                SELECT ID_parcours 
                FROM Historique 
                WHERE Historique.ID_historique = Avis.ID_historique
            )
            WHERE ID_parcours IS NULL AND ID_historique IS NOT NULL
        """)
        
        affected = cursor.rowcount
        print(f"Nombre de lignes mises à jour dans Avis : {affected}")
        
        conn.commit()
        conn.close()
        print("Terminé avec succès !")
    except Exception as e:
        print(f"Erreur : {e}")

if __name__ == "__main__":
    fix_null_parcours()
