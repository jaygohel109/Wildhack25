# WildHack25 Project

A full-stack application with a Flutter frontend and FastAPI backend, designed to provide a seamless user experience with robust authentication and data management capabilities.

## 🌟 Features

### User Management & Authentication
- Secure user registration and login system
- Role-based access control (Volunteer and Senior roles)
- Profile creation and management
- Password recovery functionality
- JWT-based authentication

### Task Management System
- Create and manage assistance tasks
- Task assignment system for volunteers
- Task status tracking (Active/Completed)
- Task matching algorithm for volunteers
- Detailed task history and tracking

### Senior Citizen Features
- Create assistance requests
- Track active assistance requests
- View task completion history
- Profile management with specific needs
- Direct communication with assigned volunteers

### Volunteer Features
- Browse available tasks
- Task matching based on skills and location
- Accept and manage multiple tasks
- Track task completion status
- View task history and impact metrics

### Technical Features
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

## 👥 Authors
- Team WildHack25

## 🙏 Acknowledgments
- Flutter Team for the amazing framework
- FastAPI community for the robust backend framework
- All contributors and team members
