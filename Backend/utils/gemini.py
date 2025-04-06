import google.generativeai as genai
import os
from dotenv import load_dotenv
from utils.database.tasks_model import Category  # Ensure Enum is reachable

# Load environment variables
load_dotenv()
print("Loaded GEMINI API key:", os.getenv("GEMINI_API_KEY"))

# Configure Gemini API
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

async def classify_task_category(description: str) -> Category:
    prompt = f"""
    You are a helpful assistant that classifies tasks into categories based on the description provided. 
    Each task belongs to one of the following categories:

    1. Technology Assistance (e.g., phone, laptop, internet issues)
    2. Transportation (e.g., need a ride, pickup/drop-off)
    3. Home Maintenance (e.g., plumbing, repairs, electric)
    4. Health & Wellness (e.g., doctor's visit, medication pickup)
    5. Companionship or Check-in (e.g., talking, video calls, loneliness support)
    6. Miscellaneous (if it does not fit the above categories)

    Given the task description below, return only the category name that best fits.

    Task Description: "{description}"

    Category:
    """

    try:
        model = genai.GenerativeModel('models/gemini-2.0-pro-exp')
        response = model.generate_content(prompt)
        category_str = response.text.strip().lower()
        
        category_map = {
            "technology assistance": Category.TECH_HELP,
            "transportation": Category.TRANSPORTATION,
            "home maintenance": Category.HOME_REPAIRS,
            "health & wellness": Category.GROCERY_SUPPORT,
            "companionship or check-in": Category.COMPANIONSHIP,
            "miscellaneous": Category.OTHER
        }
        return category_map.get(category_str, Category.OTHER)
    except Exception as e:
        print(f"Gemini classification failed: {e}")
        return Category.OTHER
