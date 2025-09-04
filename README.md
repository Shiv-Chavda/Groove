# Groove - Your go-to place to groove to your fav music

Groove is a full-stack music streaming application that allows users to discover, stream, and enjoy their favorite music. Built with Flutter for the mobile frontend and Node.js/Express for the backend, Groove provides a seamless music listening experience with features like user authentication, audio playback, search, and personalized recommendations.

## 🚀 Features

### Core Features
- **User Authentication**: Secure login and signup with JWT tokens
- **Audio Streaming**: High-quality music playback with controls (play, pause, seek, repeat)
- **Music Discovery**: Browse popular tracks and personalized recommendations
- **Search Functionality**: Find songs by title, artist, or genre
- **Like System**: Save favorite songs to your personal collection
- **User Profile**: View and manage your account information
- **Admin Panel**: Upload and manage music library (admin only)

### Technical Features
- **Cross-Platform**: Works on Android, iOS, Web, Windows, Linux, and macOS
- **Offline Support**: Local storage for user preferences and tokens
- **Real-time Updates**: Automatic token refresh for seamless sessions
- **Responsive Design**: Beautiful UI with gradient themes and smooth animations
- **Debounced Search**: Optimized search with 300ms debounce for better performance

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.0+
- **State Management**: GetX
- **Audio Player**: audioplayers
- **HTTP Client**: http package
- **Local Storage**: get_storage
- **Fonts**: Google Fonts (Lato)
- **Icons**: Material Design Icons

### Backend (Node.js)
- **Runtime**: Node.js with ESM support
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt
- **File Upload**: multer
- **Validation**: Joi
- **CSV Parsing**: csv-parse

### Development Tools
- **Package Manager**: npm
- **Process Manager**: nodemon (development)
- **Database**: MongoDB
- **Version Control**: Git

## 📋 Prerequisites

Before running this application, make sure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (included with Flutter)
- **Node.js** (14.0.0 or higher)
- **npm** (comes with Node.js)
- **MongoDB** (local installation or cloud service like MongoDB Atlas)
- **Git**

## 🔧 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/DEBJYOTIRUMAN/Galaxtune-Flutter-FullStack-Project.git
cd Galaxtune-Flutter-FullStack-Project
```

### 2. Backend Setup

#### Install Dependencies
```bash
cd Backend
npm install
```

#### Environment Configuration
Create a `.env` file in the `Backend` directory with the following variables:

```env
DEBUG_MODE=true
DB_URL=mongodb://localhost:27017/groove
JWT_SECRET=your_jwt_secret_key_here
REFRESH_SECRET=your_refresh_secret_key_here
APP_URL=http://localhost:9000
```

#### Database Setup
1. Start MongoDB service on your system
2. The application will automatically create the database and collections

#### Seed Initial Data (Optional)
```bash
npm run seed
```

This will populate the database with music data from `high_popularity_spotify_data.csv`

#### Start Backend Server
```bash
npm run dev
```

The server will start on `http://localhost:9000`

### 3. Frontend Setup

#### Install Dependencies
```bash
cd ../App
flutter pub get
```

#### Configure Environment (Optional)
For production deployment or custom host configuration:

```bash
# For production
flutter run --dart-define=PROD=true --dart-define=PROD_BASE=https://your-api-domain.com

# For custom development host/port
flutter run --dart-define=DEV_HOST=192.168.1.100 --dart-define=DEV_PORT=9000
```

#### Run the Application
```bash
flutter run
```

## 📱 Usage

### For Regular Users
1. **Launch the app** and navigate to the login screen
2. **Sign up** for a new account or **log in** with existing credentials
3. **Browse music** through the main dashboard featuring:
   - Popular tracks
   - Recommended songs
   - New releases
4. **Search** for specific songs, artists, or genres
5. **Play music** with full audio controls:
   - Play/Pause
   - Seek forward/backward
   - Repeat mode
   - Volume control
6. **Like songs** to add them to your favorites
7. **View profile** and manage your account

### For Administrators
1. **Log in** with admin credentials
2. **Upload music** through the admin panel:
   - Song title, artist, genre
   - Audio file (MP3)
   - Thumbnail images
   - Rating and recommendation status
3. **Manage music library** - update or delete existing tracks

## 🏗️ Project Structure

```
Galaxtune-Flutter-FullStack-Project/
├── App/                          # Flutter Frontend
│   ├── lib/
│   │   ├── api.dart             # API configuration
│   │   ├── main.dart            # App entry point
│   │   ├── login_page.dart      # Authentication
│   │   ├── signup_page.dart     # User registration
│   │   ├── audiobook_page.dart  # Main music dashboard
│   │   ├── audioplay_page.dart  # Audio player interface
│   │   ├── search.dart          # Search functionality
│   │   ├── profile_page.dart    # User profile
│   │   ├── colors.dart          # Theme colors
│   │   ├── store.dart           # GetX storage utilities
│   │   └── env.dart             # Environment configuration
│   ├── assets/                  # Static assets
│   ├── pubspec.yaml             # Flutter dependencies
│   └── android/ios/             # Platform-specific code
├── Backend/                      # Node.js Backend
│   ├── config/
│   │   └── index.js             # Environment configuration
│   ├── controllers/
│   │   ├── index.js
│   │   ├── musicController.js   # Music CRUD operations
│   │   └── auth/                # Authentication controllers
│   ├── middlewares/
│   │   ├── auth.js              # JWT authentication
│   │   ├── admin.js             # Admin authorization
│   │   └── errorHandler.js      # Error handling
│   ├── models/
│   │   ├── index.js
│   │   ├── music.js             # Music schema
│   │   ├── user.js              # User schema
│   │   └── refreshToken.js      # Token schema
│   ├── routes/
│   │   └── index.js             # API routes
│   ├── services/                # Business logic
│   ├── validators/              # Input validation
│   ├── scripts/
│   │   └── seed.js              # Database seeding
│   ├── music/                   # Uploaded music files
│   ├── package.json             # Node.js dependencies
│   └── server.js                # Server entry point
└── README.md                    # Project documentation
```

## 🔌 API Endpoints

### Authentication
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `GET /api/me` - Get current user info
- `POST /api/refresh` - Refresh access token
- `POST /api/logout` - User logout

### Music
- `GET /api/music` - Get all music (authenticated)
- `POST /api/music` - Upload new music (admin only)
- `PUT /api/music/:id` - Update music (admin only)
- `DELETE /api/music/:id` - Delete music (admin only)
- `PUT /api/music/like/:id` - Like/unlike music
- `GET /api/music/search?q=query` - Search music
- `GET /api/music/:filename` - Stream audio file

### Static Files
- `GET /music/*` - Serve uploaded music files

## 🎨 UI/UX Design

The application features a modern, music-focused design with:

- **Gradient Backgrounds**: Beautiful color gradients for visual appeal
- **Material Design**: Consistent with Material Design principles
- **Smooth Animations**: GetX-powered transitions between screens
- **Responsive Layout**: Adapts to different screen sizes
- **Dark Theme**: Music-centric color scheme with proper contrast
- **Intuitive Navigation**: Bottom navigation and gesture-based controls

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt for secure password storage
- **Input Validation**: Joi schemas for API input validation
- **File Upload Security**: Restricted file types and size limits
- **CORS Protection**: Configured CORS policies
- **Error Handling**: Comprehensive error handling and logging

## 🚀 Deployment

### Backend Deployment
1. Set up a MongoDB database (local or cloud)
2. Configure environment variables for production
3. Build and deploy to a hosting service (Heroku, Railway, Render, etc.)
4. Update the `APP_URL` in environment variables

### Frontend Deployment
1. Configure the production API URL
2. Build platform-specific binaries:
   ```bash
   # Android APK
   flutter build apk --release

   # iOS (requires macOS)
   flutter build ios --release

   # Web
   flutter build web --release
   ```
3. Deploy to respective app stores or web hosting

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart best practices
- Write clear, concise commit messages
- Test your changes thoroughly
- Update documentation as needed
- Ensure code is properly formatted

## 📝 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

**Shiv Chavda**
- Email: shivchavda11@gmail.com

## 🙏 Acknowledgments

- Original project by Debjyoti Das
- Spotify dataset for initial music data
- Flutter and Node.js communities for excellent documentation
- All contributors and users of the Groove application

---

**Note**: This application is for educational and personal use. Please ensure you have proper licensing for any music content used in production.
