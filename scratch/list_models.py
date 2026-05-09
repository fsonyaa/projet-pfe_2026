import google.generativeai as genai

GEMINI_API_KEY = "AIzaSyBaiHnkGJPQBw9GSRiydd3VYKNNXOiuIFQ"
genai.configure(api_key=GEMINI_API_KEY)

print("Liste des modèles disponibles :")
for m in genai.list_models():
    if 'generateContent' in m.supported_generation_methods:
        print(m.name)
