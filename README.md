# 🌟 KindConnect – Empowering Seniors, Enabling Kindness

What if technology could do more than just connect us — what if it could **care** for us?

**KindConnect** is more than an app. It’s a movement — a full-stack platform built with Flutter and FastAPI that empowers **senior citizens** to request everyday help and enables **volunteers** to step in with compassion and ease. From setting up a device to getting a ride to the doctor, help is now just a click away — and it’s human.

We all have someone in our lives — a grandparent, a neighbor, a parent — who deserves to feel safe, supported, and connected. KindConnect exists to make sure no senior is left behind simply because they didn’t have the right person at the right time.

This is Uber, but for **kindness**.

This is tech for **dignity**.

This is **wellness, productivity**, and **empathy** in action.

## 💡 Why KindConnect?

In an age where loneliness among seniors is rising, many are left to struggle with tasks that seem small — yet feel enormous. Meanwhile, thousands of capable, kind-hearted people are ready to help — but lack the structure, tools, or awareness to act.

KindConnect bridges that gap:

- Seniors can **request help** for daily challenges.
- Volunteers get **smartly matched** to tasks they’re equipped to handle.
- Real-time updates create **peace of mind** on both ends.
- A reward system helps **celebrate every act of care**.
Every interaction isn’t just a task completed — it’s a relationship started. It’s trust rebuilt. It’s human connection, powered by AI.

## 🎯 Track Alignment

### 📈 Productivity / Wellness (Primary)
- **Wellness**: Reduces senior isolation, anxiety, and helplessness by offering timely, real-world support.
- **Productivity**: Provides volunteers with meaningful opportunities to contribute — building purpose, community, and joy.

## 🔧 Features Overview

### 🧓 Senior-Centered Design
- Submit help requests with ease
- Track ongoing and completed tasks
- Receive real-time updates and ETA notifications
- Communicate directly with volunteers
- Build a profile that highlights personal needs and preferences

### 🙋 Volunteer Empowerment
- Browse or auto-match to tasks that fit skills and schedule
- Accept, complete, and track task progress
- View history and personal impact metrics
- Earn rewards for consistent contributions

### 🤖 AI-Driven Matching & Trust
- Uses natural language processing and user profiles to pair the right helper with the right task
- Learns preferences over time to increase accuracy
- Enables fair distribution of opportunities

## 🔐 Built with Safety in Mind

Security and trust are essential in any care network. That’s why KindConnect includes:

- Role-based access (Senior vs Volunteer)
- Encrypted credentials and JWT authentication
- Real-time progress tracking
- Secure password recovery
- Input validation, error monitoring, and rate limiting

## Technical Features

#### Frontend (Flutter)
- Modern and responsive UI design
- Cross-platform support (iOS, Android, Web)
- Material Design implementation
- Custom font integration (Nunito)
- Asset management for images and resources
- Secure API integration with backend
- State management for real-time updates
- Offline data persistence
- Push notifications support

#### Backend (FastAPI)
- RESTful API endpoints with FastAPI
- Secure authentication system with JWT
- MongoDB database integration
- Environment variable configuration
- Comprehensive logging system
- Task matching algorithm
- Real-time task updates
- Data validation and sanitization
- Error handling and monitoring
- API rate limiting and security measures

### Security Features
- Password hashing with bcrypt
- JWT token-based authentication
- Secure password reset mechanism
- Input validation and sanitization
- Protected API endpoints
- Session management
- Rate limiting protection

## 🛠️ Tech Stack

### Frontend Dependencies
- Flutter SDK (>=3.2.3)
- Core Dependencies:
  - http: ^0.13.6 (API communication)
  - flutter_svg: ^2.0.7 (SVG rendering)
  - intl: ^0.18.1 (Internationalization)
  - cupertino_icons: ^1.0.2 (iOS style icons)

### Backend Dependencies
- Python packages:
  - fastapi (Web framework)
  - uvicorn (ASGI server)
  - python-dotenv (Environment management)
  - pydantic (Data validation)
  - passlib (Password hashing)
  - motor (MongoDB async driver)
  - python-jose[jwt] (JWT authentication)
  - bcrypt (Password hashing)
  - google-generativeai (Google Gemini)

## 📝 Prerequisites
- Python 3.8+
- Flutter SDK
- MongoDB
- Node.js and npm (for development)

## 🚀 Getting Started

### Backend Setup
1. Navigate to the Backend directory:
   ```bash
   cd Backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Set up environment variables:
   Create a `.env` file with the following:
   ```
   MONGODB_URL=your_mongodb_url
   MONGO_DB_USERNAME=your_username
   MONGODB_PASSWORD=your_password
   GEMINI_API_KEY=YOUR_GEMINI_API_KEY
   ```

5. Run the server:
   ```bash
   python3 endpoints.py
   ```

### Frontend Setup
1. Navigate to the frontend directory:
   ```bash
   cd frontend_app
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## 📁 Project Structure
```
.
├── Backend/
│   ├── utils/
│   ├── mapping-list/
│   ├── logs/
│   ├── endpoints.py
│   ├── main.py
│   └── requirements.txt
├── frontend_app/
│   ├── lib/
│   ├── assets/
│   ├── test/
│   └── pubspec.yaml
└── README.md
```

## 🤝 Contributing
Feel free to submit issues and enhancement requests.

## 📄 License
This project is licensed under the terms of the LICENSE file included in the repository.

## 🤝 How You Can Help
Every coder has a grandparent in their heart.

Every volunteer has a story worth sharing.

Every judge has someone they wish could live with a little more peace, a little more dignity.

We built KindConnect for them.
We hope you feel them in every line of code we wrote.

Join us in making compassion scalable. 💜