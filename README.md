# FlutterPost - Social Media App

A modern, offline-first social media application built with Flutter. This app demonstrates advanced Flutter concepts, clean architecture, and best practices for building scalable mobile applications.

![Flutter Version](https://img.shields.io/badge/Flutter-3.19.0-blue)
![Dart Version](https://img.shields.io/badge/Dart-3.3.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 🌟 Features

## 📱 Screenshots

<p float="left">
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2025-02-10 at 11.30.54.png" width="150" />
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2025-02-10 at 11.32.28.png" width="150" /> 
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2025-02-10 at 11.32.49.png" width="150" />
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2025-02-10 at 11.33.08.png" width="150" />
  <img src="Simulator Screenshot - iPhone 16 Pro Max - 2025-02-10 at 11.33.31.png" width="150" />
</p>

_From left to right: Login, Feed, Create Post, Profile, and Comments screens_

### Core Features

- **Offline-First Architecture**: Seamless experience using Firebase offline persistence
- **Real-Time Updates**: Instant post, like, and comment synchronization
- **Image Handling**: Upload and cache images for optimal performance
- **Authentication**: Secure Firebase-based authentication system

### User Features

- **Posts Management**
  - Create text posts with image uploads
  - View feed with real-time updates
  - Like/unlike posts
  - Comment on posts
  - Delete own posts and comments
- **Profile Management**
  - Customizable user profiles
  - Profile picture upload
  - View other users' profiles
  - Activity history
- **Offline Capabilities**
  - Create posts while offline
  - View cached content
  - Automatic synchronization when online
  - Built-in Firebase conflict resolution

## 🔧 Technical Stack

- **Frontend**: Flutter & Dart
- **State Management**: BLoC Pattern
- **Backend & Offline Storage**: Firebase
  - Firestore with offline persistence
  - Firebase Auth for authentication
  - Firebase Storage for media
  - Firebase local caching
- **Image Handling**: Cached Network Image
- **Testing**: Flutter Test Framework

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.19.0)
- Dart (>=3.3.0)
- Firebase CLI
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation Steps

1. **Clone the Repository**

   ```bash
   git clone git@github.com:Jaman-dedy/social_media.git
   cd flutter-post
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Enable offline persistence in Firebase configuration
   - Download and add Firebase configuration files:
     - For Android: `google-services.json` to `android/app/`
     - For iOS: `GoogleService-Info.plist` to `ios/Runner/`
     - For Web: Add the configuration in `web/index.html`

4. **Run the App**

   ```bash
   # For Android
   flutter run -d android

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome
   ```

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

Key test areas include:

- Authentication flows
- Post creation and synchronization
- Offline functionality
- UI component tests

## 🏗️ Architecture

The app follows Clean Architecture principles with the following layers:

```
lib/
├── core/               # Core functionality and utilities
├── data/              # Data layer (repositories, data sources)
├── domain/            # Business logic and entities
├── presentation/      # UI layer (screens, widgets)
└── application/       # Application layer (BLoC)
```

## 🔄 State Management

We use the BLoC pattern for state management, providing:

- Clear separation of concerns
- Predictable state updates
- Easy testing
- Efficient rebuilds

## 🌐 Offline Functionality

The app leverages Firebase's robust offline capabilities:

- Automatic offline data persistence
- Real-time synchronization when online
- Built-in conflict resolution
- Efficient data caching
- Optimistic UI updates

### Firebase Offline Features Used:

- Firebase Firestore offline persistence
- Cached query results
- Background synchronization
- Automatic conflict resolution
- Local cache for Firebase Storage

## 🎯 Future Enhancements

- Push notifications
- Story feature
- Direct messaging
- Advanced feed algorithms
- Content moderation
- Enhanced analytics

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the robust backend services and offline capabilities
- The open-source community for various packages used
