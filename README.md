# Kindered App

A modern Flutter application built with GetX for state management, following clean architecture principles. The app features a beautiful UI with custom theming, smooth animations, and a modular structure for better maintainability.

## ✨ Features

- 🎨 Beautiful, responsive UI with custom theming
- ⚡ State management with GetX
- 🛣️ Named routing with parameters
- 🌍 Multi-language support (i18n)
- 📱 Responsive design for multiple screen sizes
- 🔄 Clean architecture and modular structure
- 🔒 Secure storage with shared preferences
- 🗺️ Location services integration
- 🎭 Custom animations and transitions


## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.8.1)
- Dart SDK (>=3.1.0)
- Android Studio / VS Code with Flutter extensions
- Android Emulator or physical device for testing

### 🛠️ Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Atik-hridoy/kindered_app.git
   cd kindered_app
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── assets/               # App assets (images, fonts, svg)
│   ├── font/            # Custom fonts
│   ├── images/          # Image assets
│   └── svg/             # SVG assets
│
├── config/              # App configurations
│   ├── app_bindings.dart
│   ├── app_page.dart
│   ├── app_routes.dart  # All app routes
│   └── app_theme.dart   # App theming
│
├── core/                # Core functionality
│   └── localization/    # Internationalization
│
├── modules/             # Feature modules
│   ├── accounts_setting/
│   │   ├── binding/     # Dependency injections
│   │   └── view/        # UI screens
│   │
│   ├── auth/            # Authentication module
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/
│   │
│   ├── home/            # Home module
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/
│   │
│   ├── location/        # Location services
│   │   └── bindings/
│   │
│   └── profile_and_settings/  # Profile & settings
│       ├── bindings/
│       ├── view/
│       └── widgets/
│
└── main.dart           # App entry point
```

## 📱 Screens

- Splash Screen
- Onboarding
- Login / Sign Up
- Home Feed
- User Profile
- Account Settings
- Location Settings
- Terms & Conditions
- Help & Support
- About Us

## 🛠️ Dependencies

- `get`: ^4.7.2 - State management and dependency injection
- `flutter_svg`: ^2.0.10+1 - SVG rendering
- `shared_preferences`: ^2.5.3 - Local storage
- `smooth_page_indicator`: ^1.2.1 - Page indicators
- `dotted_border`: ^3.1.0 - Dotted border containers
- `location`: ^5.0.0 - Location services
- `flutter_screenutil`: ^5.9.0 - Responsive UI
- `intl`: ^0.19.0 - Internationalization
- `google_fonts`: ^6.1.0 - Custom fonts
- `http`: ^1.5.0 - HTTP requests

## 🎨 UI/UX

The app follows Material Design 3 guidelines with a custom color scheme and typography. It includes:

- Dark/Light theme support
- Custom animations and transitions
- Responsive layouts
- Reusable widgets
- Consistent spacing and typography

## 🔧 Configuration

1. Update app name and package name in:
   - `pubspec.yaml`
   - Android: `android/app/build.gradle`
   - iOS: `ios/Runner/Info.plist`

2. Update app icons:
   - Android: `android/app/src/main/res/`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ✉️ Contact

- [Atik Hridoy](https://github.com/Atik-hridoy)
- Project Link: [https://github.com/Atik-hridoy/kindered_app](https://github.com/Atik-hridoy/kindered_app)

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Material Design 3](https://m3.material.io/)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
