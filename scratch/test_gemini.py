import google.generativeai as genai
import json

# Ta clé API
GEMINI_API_KEY = "AIzaSyBaiHnkGJPQBw9GSRiydd3VYKNNXOiuIFQ"
genai.configure(api_key=GEMINI_API_KEY)

def test_gemini():
    print("Test de l'API Gemini en cours...")
    try:
        model = genai.GenerativeModel('gemini-flash-latest')
        comment = "el chafer yijri barcha w mayehtaramch el krahba" # Exemple en Derja
        
        prompt = f"""
        Analyse ce commentaire de transport public (en Français ou Derja Tunisienne) :
        "{comment}"
        
        Réponds uniquement en JSON avec ces champs exacts :
        {{
          "sentiment": "Positif" | "Négatif" | "Neutre",
          "score": float entre -1.0 et 1.0,
          "category": "Chauffeur" | "Confort" | "Véhicule" | "Service" | "Sécurité",
          "keywords": "mot1, mot2, ...",
          "risk": "Oui" | "Non"
        }}
        """
        
        response = model.generate_content(prompt)
        res_text = response.text.replace('```json', '').replace('```', '').strip()
        ai_data = json.loads(res_text)
        
        print("\nAPI fonctionne parfaitement !")
        print(f"Commentaire teste : {comment}")
        print("-" * 30)
        print(f"Sentiment : {ai_data['sentiment']}")
        print(f"Score : {ai_data['score']}")
        print(f"Categorie : {ai_data['category']}")
        print(f"Mots-cles : {ai_data['keywords']}")
        print(f"Alerte Securite : {ai_data['risk']}")
        print("-" * 30)
        
    except Exception as e:
        print(f"\nErreur lors du test : {e}")

if __name__ == "__main__":
    test_gemini()
