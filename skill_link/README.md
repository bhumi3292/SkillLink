# SkillLink Mobile App

A cross-platform Flutter application for the SkillLink Service platform. This mobile app provides a seamless experience for professionals (workers) and hirers to manage service bookings, payments, and more.

## 📱 Features

### Core Features
- **Professional Exploration**: Browse and search workers with rich media and skills.
- **User Authentication**: Secure login/signup for both workers and hirers.
- **Worker Profile Management**: Add, edit, and manage professional profiles.
- **Booking System**: Schedule and manage service visits.
- **Payment Integration**: Secure payments via Khalti and eSewa.
- **AI Chatbot**: Intelligent floating assistant for user support and guidance.
- **Favorites System**: Save and organize favorite service providers.
- **User Profiles**: Manage personal information, roles, and preferences.
- **Real-time Updates**: Live notifications for booking status and messages.

### Technical Features
- **Cross-platform**: Full support for both iOS and Android.
- **Offline Support**: Reliable basic functionality without internet.
- **Push Notifications**: Instant updates on booking and account activity.
- **Image/Video Support**: Showcase professional work through high-quality media.
- **Responsive Design**: Flawless UI across various screen sizes and devices.
- **Dark/Light Theme**: Support for system-wide and manual theme switching.

## 🏗️ Architecture

### Clean Architecture
The app follows Clean Architecture principles with a robust separation of concerns:

```
lib/
├── app/                    # Application layer
│   ├── app.dart           # Main app configuration
│   ├── constant/          # App constants & API endpoints
│   ├── service_locator/   # Dependency injection setup
│   ├── shared_pref/       # Local storage management
│   └── theme/             # Styling & design system
├── cores/                 # Shared core modules
│   ├── common/            # Reusable UI components
│   ├── error/             # Global error handling
│   ├── network/           # API & Socket connectivity
│   └── utils/             # Helper functions & extensions
├── features/              # Modular feature domains
│   ├── auth/              # Identity & Access management
│   ├── booking/           # Service scheduling logic
│   ├── chatbot/           # AI interaction system
│   ├── explore/           # Discovery & search engine
│   ├── profile/           # User account management
│   ├── add_worker/        # Profile creation & verification
│   ├── favourite/         # Collection management
│   └── ...
└── main.dart              # Application entry point
```

### State Management
- **BLoC Pattern**: Predictable state management using Business Logic Components.
- **Repository Pattern**: Clean data abstraction for local and remote sources.
- **Dependency Injection**: Decoupled components using GetIt.

## 🛠️ Technology Stack

### Core Dependencies
- **Flutter**: Modern UI toolkit for cross-platform development.
- **flutter_bloc**: Robust state management.
- **dio**: Efficient HTTP client for API interactions.
- **get_it**: Service locator for dependency injection.
- **equatable**: Simplified object comparison.
- **dartz**: Functional programming constructs for error handling.

### UI & Media
- **cached_network_image**: Advanced image caching.
- **fluttertoast**: Non-intrusive user feedback.
- **lottie**: High-performance vector animations.
- **table_calendar**: Comprehensive date management.
- **image_picker**: seamless media selection.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Android SDK (Level 30+) / Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd skill_link
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Update API endpoints in `lib/app/constant/api_endpoints.dart`
   - Ensure the backend server is reachable from the device/emulator.

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔐 Security
- **JWT Authentication**: Industry-standard secure token management.
- **Encrypted Storage**: Sensitive data saved using secure local storage.
- **Role-Based Access**: Strict separation between Worker and Hirer permissions.

## 📊 Performance
- **Lazy Loading**: Smooth scrolling with on-demand data fetching.
- **Asset Optimization**: Efficient handling of media and animation files.
- **Memory Management**: Proactive cleanup of unused resources and listeners.

---

**SkillLink Mobile** - connecting talent with opportunity! 🛠️📱
