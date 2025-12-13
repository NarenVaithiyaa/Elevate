# Habit Tracker MVP

A minimal, bright, modern habit tracker and task manager built with Flutter.

## Features

*   **Habit Tracking**: Create and track daily habits.
*   **Task Management**: Manage your to-do list efficiently.
*   **Visual Analytics**: View your progress with interactive charts (using `fl_chart`).
*   **Calendar View**: Track habits over time with a calendar interface (using `table_calendar`).
*   **Authentication**: Secure login with Firebase Auth and Google Sign-In.
*   **Cloud Sync**: Data is synced across devices using Cloud Firestore.
*   **Local Notifications**: Get reminders for your habits.
*   **Biometric Security**: Secure your data with local authentication (Fingerprint/Face ID).
*   **Geolocation**: Location-based features (using `geolocator`).

## Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
*   [Git](https://git-scm.com/) installed.
*   A Firebase project set up.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/habit_tracker_mvp.git
    cd habit_tracker_mvp
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Environment Setup:**

    This project uses `flutter_dotenv` to manage sensitive keys. You need to create a `.env` file in the root directory of the project.

    Create a file named `.env` and add your Firebase configuration keys:

    ```env
    FIREBASE_ANDROID_API_KEY=your_api_key
    FIREBASE_ANDROID_APP_ID=your_app_id
    FIREBASE_ANDROID_MESSAGING_SENDER_ID=your_messaging_sender_id
    FIREBASE_ANDROID_PROJECT_ID=your_project_id
    ```

4.  **Firebase Configuration:**

    *   **Android**: Download your `google-services.json` file from the Firebase Console and place it in `android/app/`.
    *   **iOS**: Download your `GoogleService-Info.plist` file from the Firebase Console and place it in `ios/Runner/`.

## Running the App

To run the app on a connected device or emulator:

```bash
flutter run
```

## Building the App

### Android

To build an APK file for Android:

```bash
flutter build apk --release
```

The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

To build an App Bundle (for Play Store):

```bash
flutter build appbundle --release
```

### iOS

To build for iOS (requires macOS):

```bash
flutter build ios --release
```

## Project Structure

*   `lib/`: Contains the Dart source code.
    *   `models/`: Data models.
    *   `providers/`: State management (Provider).
    *   `screens/`: UI screens.
    *   `services/`: API and backend services.
    *   `widgets/`: Reusable UI components.
    *   `utils/`: Helper functions and constants.
*   `assets/`: Images, icons, and configuration files.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
