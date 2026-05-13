import requests
import json

def test():
    try:
        # Test local connection
        print("Testing http://127.0.0.1:8000/get_lignes ...")
        r = requests.get("http://127.0.0.1:8000/get_lignes", timeout=5)
        print(f"Status: {r.status_code}")
        if r.status_code == 200:
            data = r.json()
            print(f"Success! Found {len(data)} lignes.")
        else:
            print(f"Error: {r.text}")
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    test()
