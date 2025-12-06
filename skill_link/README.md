# SkillLink Mobile App

A cross-platform Flutter application for the SkillLink Workerrental platform. This mobile app provides a seamless experience for workers and Hirers to manage Workerrentals, bookings, payments, and more.

## 📱 Features

### Core Features
- **WorkerExploration**: Browse and search properties with rich media
- **User Authentication**: Secure login/signup for workers and Hirers
- **WorkerManagement**: Add, edit, and manage Workerlistings (workers)
- **Booking System**: Schedule and manage Workervisits
- **Payment Integration**: Khalti and eSewa payment gateways
- **AI Chatbot**: Floating assistant for user support
- **Favorites System**: Save and organize favorite properties
- **User Profiles**: Manage personal information and preferences
- **Real-time Updates**: Live notifications and status updates

### Technical Features
- **Cross-platform**: iOS and Android support
- **Offline Support**: Basic offline functionality
- **Push Notifications**: Real-time updates
- **Image/Video Support**: Rich media for properties
- **Responsive Design**: Adapts to different screen sizes
- **Dark/Light Theme**: User preference support

## 🏗️ Architecture

### Clean Architecture
The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── app/                    # Application layer
│   ├── app.dart           # Main app configuration
│   ├── constant/          # App constants
│   ├── service_locator/   # Dependency injection
│   ├── shared_pref/       # Shared preferences
│   └── theme/             # App theming
├── cores/                 # Core utilities
│   ├── common/            # Common widgets
│   ├── error/             # Error handling
│   ├── network/           # Network utilities
│   └── utils/             # Utility functions
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── booking/           # Booking system
│   ├── chatbot/           # AI chatbot
│   ├── explore/           # Workerexploration
│   ├── profile/           # User profiles
│   ├── add_property/      # Workermanagement
│   ├── favourite/         # Favorites system
│   └── ...
└── main.dart              # App entry point
```

### State Management
- **BLoC Pattern**: Business Logic Component for state management
- **Repository Pattern**: Data abstraction layer
- **Dependency Injection**: GetIt service locator

## 🛠️ Technology Stack

### Core Dependencies
- **Flutter**: 3.7+ (Cross-platform framework)
- **Dart**: Latest stable version
- **flutter_bloc**: State management
- **dio**: HTTP client
- **get_it**: Dependency injection
- **equatable**: Value equality
- **dartz**: Functional programming

### UI Dependencies
- **cached_network_image**: Image caching
- **fluttertoast**: Toast notifications
- **lottie**: Animations
- **table_calendar**: Calendar widget
- **image_picker**: Image selection
- **permission_handler**: Permissions

### Storage Dependencies
- **hive_flutter**: Local database
- **shared_preferences**: Key-value storage
- **path_provider**: File system access

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7+)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

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
   - Copy `.env.example` to `.env`
   - Update API endpoints in `lib/app/constant/api_endpoints.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

```bash
# Debug build
flutter run

# Release build for Android
flutter build apk --release

# Release build for iOS
flutter build ios --release

# Web build
flutter build web
```

## 📱 App Structure

### Feature Modules

#### Authentication (`features/auth/`)
- User login/signup
- JWT token management
- Role-based access (worker/Hirer)

#### WorkerExploration (`features/explore/`)
- Workerlisting
- Search and filtering
- Workerdetails
- Image galleries

#### Booking System (`features/booking/`)
- Schedule visits
- Manage availability
- Booking history
- Calendar integration

#### Chatbot (`features/chatbot/`)
- AI-powered assistant
- Floating interface
- Real-time responses
- Context awareness

#### Profile Management (`features/profile/`)
- User profiles
- Settings
- Preferences
- Account management

#### WorkerManagement (`features/add_property/`)
- Add new properties
- Edit existing properties
- Media upload
- Category management

## 🔧 Configuration

### API Configuration
Update `lib/app/constant/api_endpoints.dart`:

```dart
class ApiEndpoints {
  static const String baseUrl = 'http://your-api-url:3001/api/';
  static const String login = '${baseUrl}auth/login';
  static const String register = '${baseUrl}auth/register';
  // ... other endpoints
}
```

### Theme Configuration
Customize `lib/app/theme/app_theme.dart`:

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF003366),
      // ... theme configuration
    );
  }
}
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widgets/
```

### Integration Tests
```bash
flutter test integration_test/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📦 Dependencies

### Production Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1
  dio: ^5.0.0
  get_it: ^8.0.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  cached_network_image: ^3.3.1
  # ... see pubspec.yaml for complete list
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  bloc_test: ^10.0.0
  build_runner: ^2.4.6
  # ... see pubspec.yaml for complete list
```

## 🔐 Security

### Authentication
- JWT token-based authentication
- Secure token storage
- Automatic token refresh
- Role-based access control

### Data Protection
- HTTPS communication
- Input validation
- SQL injection prevention
- XSS protection

## 📊 Performance

### Optimization Techniques
- Image caching and compression
- Lazy loading for lists
- Memory management
- Network request optimization
- Background processing

### Monitoring
- Performance profiling
- Memory leak detection
- Network request monitoring
- Error tracking

## 🚀 Deployment

### Android Deployment
1. Update `android/app/build.gradle`
2. Configure signing keys
3. Build APK: `flutter build apk --release`
4. Upload to Google Play Store

### iOS Deployment
1. Update `ios/Runner/Info.plist`
2. Configure certificates
3. Build: `flutter build ios --release`
4. Upload to App Store Connect

### Web Deployment
1. Build: `flutter build web`
2. Deploy to hosting service (Firebase, Netlify, etc.)

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### Dependency Issues
```bash
# Update dependencies
flutter pub upgrade
flutter pub outdated
```

#### Platform-Specific Issues
- **Android**: Check SDK versions and permissions
- **iOS**: Verify certificates and provisioning profiles
- **Web**: Check browser compatibility

### Debug Mode
Enable debug prints in `lib/cores/network/api_service.dart`:

```dart
// Uncomment for detailed API logging
PrettyDioLogger(
  requestHeader: true,
  requestBody: true,
  responseHeader: true,
  responseBody: true,
)
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Add tests for new functionality
5. Run tests: `flutter test`
6. Commit your changes: `git commit -m 'Add feature'`
7. Push to branch: `git push origin feature-name`
8. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the feature-specific README files
- **Issues**: Create an issue in the repository
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact the development team

## 🔄 Version History

- **v1.0.0** - Initial release
- **v1.1.0** - Added payment integration
- **v1.2.0** - Added AI chatbot
- **v1.3.0** - Performance improvements
- **v1.4.0** - UI/UX enhancements

---

**SkillLink Mobile** - Your Workerrental companion! 🏠📱
