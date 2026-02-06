
import os
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv("mcp_server/.env")

def list_models():
    api_key = os.getenv("GOOGLE_API_KEY")
    client = genai.Client(api_key=api_key)
    
    print("Available models:")
    for model in client.models.list():
        print(f"Name: {model.name}, Actions: {model.supported_actions}")

if __name__ == "__main__":
    list_models()
