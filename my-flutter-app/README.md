# My Flutter App

This is a Flutter application that includes a splash screen and a home screen. The app demonstrates basic navigation and state management in Flutter.

## Project Structure

```
my-flutter-app
├── android                # Android platform-specific code
├── ios                    # iOS platform-specific code
├── lib                    # Main application code
│   ├── main.dart          # Entry point of the application
│   ├── screens            # Contains screen widgets
│   │   ├── splash_screen.dart  # Splash screen widget
│   │   └── home_screen.dart    # Home screen widget
├── test                   # Test files
│   └── widget_test.dart   # Widget tests for the application
├── pubspec.yaml           # Flutter project configuration
└── README.md              # Project documentation
```

## Features

- Splash Screen: Displays a logo and navigates to the home screen after a specified duration.
- Home Screen: Displays the main content of the application.

## Getting Started

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd my-flutter-app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run
   ```

## Testing

To run the widget tests, use the following command:
```
flutter test
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.