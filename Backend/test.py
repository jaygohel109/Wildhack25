import google.generativeai as genai

# Replace 'YOUR_API_KEY' with your actual API key
genai.configure(api_key="AIzaSyAG6GwhjhDAAR3vS_AOe8GQIV_wMi56Jeo")

try:
    model = genai.GenerativeModel('models/gemini-2.0-pro-exp')
    prompt = "Write a short poem about spring."
    response = model.generate_content(prompt)
    print(response.text)
except Exception as e:
    print(f"Error generating content: {e}") 