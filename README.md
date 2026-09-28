# Grin Technologies - Flutter Machine Test Assignment

A robust, production-grade Flutter application implementing **Firebase Authentication**, **API Integration with Pagination**, **Pull-to-Refresh**, **Cached Image Loading**, and **Clean MVVM Architecture with the Repository Pattern**.

---

## 📱 Features

### 1. User Authentication (Firebase)
- **Firebase Email & Password Authentication**: Secure sign up and login.
- **Login Screen**: Clean Material 3 UI with email/password validation and visibility toggle.
- **Signup Screen**: Account creation with password confirmation ($\ge 6$ chars) and automatic redirect to the Login screen with pre-filled email.
- **Logout Functionality**: Sign out action from the main user directory with confirmation dialog.
- **Session Routing**: `AuthWrapper` automatically routes between Login and Authenticated views based on real-time auth state.

### 2. User Directory & API Integration
- **Endpoint**: `https://reqres.in/api/users`
- **Method**: `GET`
- **Headers**: Custom header `x-api-key: reqres_32e47dacd4744f009b24358d68f0272d`
- **Query Params**: `page={page}&per_page=5`
- Displays user **Avatar**, **Full Name**, **Email**, and user ID badge.

### 3. Pagination & Infinite Scroll
- Loads **5 records per page** matching API specifications.
- Listens to scroll position via `ScrollController` and automatically fetches the next page when nearing the bottom.
- Displays a bottom pagination loader during page fetches.
- Displays an end-of-list indicator when all pages have been loaded.

### 4. Pull-to-Refresh
- Integrated with `RefreshIndicator` to reset and reload the directory from page 1 using a swipe-down gesture.

### 5. UI/UX & Error Handling
- **Image Caching**: Smooth image rendering with `cached_network_image`, including loading placeholders and error fallbacks.
- **Loading States**: Full-screen loader for initial load, subtle footer spinner during pagination.
- **Error States**: Dedicated error views with a "Retry" button on network failure.
- **Friendly Auth Error Messages**: Maps Firebase error codes (e.g. `invalid-credential`, `email-already-in-use`, `CONFIGURATION_NOT_FOUND`) to human-readable explanations.

---

## 🏗️ Architecture: MVVM + Repository Pattern

The project follows a modular, feature-first **MVVM (Model-View-ViewModel)** architectural pattern with the **Repository Pattern** for decoupling data access from business logic.

```
lib/
├── core/                                    # Shared Core Module
│   ├── constants/
│   │   └── api_constants.dart               # API endpoints, headers & configuration
│   ├── errors/
│   │   └── app_exception.dart               # Custom domain exceptions
│   └── services/
│       └── api_service.dart                 # Centralized Dio HTTP service
├── feature/
│   ├── auth/                                # Auth Feature Module
│   │   ├── models/
│   │   │   └── user_model.dart              # Authenticated user representation
│   │   ├── services/
│   │   │   └── auth_service.dart            # Firebase Auth communication & error mapping
│   │   ├── viewmodels/
│   │   │   └── auth_viewmodel.dart          # Auth state management (ChangeNotifier)
│   │   └── views/
│   │       ├── auth_wrapper.dart            # Reactive session router
│   │       ├── login_view.dart              # Login screen
│   │       ├── signup_view.dart             # Signup screen
│   │       └── home_view.dart               # User dashboard & logout fallback
│   └── users/                               # User Directory Feature Module
│       ├── models/
│       │   └── users_response.dart          # Paginated API response & ApiUser model
│       ├── repositories/
│       │   └── user_repository.dart         # Repository pattern consuming ApiService
│       ├── viewmodels/
│       │   └── user_list_viewmodel.dart     # User list state & pagination logic
│       └── views/
│           ├── user_list_view.dart          # Main users list screen
│           └── widgets/
│               └── user_card.dart           # Reusable user item card with cached avatar
├── firebase_options.dart                    # FlutterFire configuration
└── main.dart                                # Application entry point & theme configuration
```

---

## 📦 Libraries Used

- **Networking**: [`dio`](https://pub.dev/packages/dio) — Robust HTTP client configured with timeouts, custom headers, and structured error handling.
- **Image Caching**: [`cached_network_image`](https://pub.dev/packages/cached_network_image) — Efficient image caching with placeholder and error widgets.
- **Firebase Auth**: [`firebase_auth`](https://pub.dev/packages/firebase_auth) & [`firebase_core`](https://pub.dev/packages/firebase_core) — User authentication and lifecycle management.
- **State Management**: Native Flutter `ChangeNotifier` + `ListenableBuilder` — Zero unnecessary bloat, highly testable, and reactive.

---

## 🚀 Setup & Run Instructions

### Prerequisites
- Flutter SDK (>= 3.12.2)
- Android Studio / Xcode / VS Code
- Android device or emulator with Google Play Services (or iOS simulator)

### 1. Clone & Install Dependencies
```bash
git clone <repository_url>
cd grin_demo
flutter pub get
```

### 2. Firebase Configuration
Firebase is pre-configured via `firebase_options.dart` and `android/app/google-services.json`.
Make sure the **Email/Password** provider is enabled in your Firebase Console under:
**Firebase Console &rarr; Build &rarr; Authentication &rarr; Sign-in method &rarr; Email/Password &rarr; Enable &rarr; Save**.

### 3. Run the Application
```bash
flutter run
```

### 4. Run Unit Tests
```bash
flutter test
```

### 5. Run Static Code Analysis
```bash
flutter analyze
```

---

## 🧪 Testing Coverage

The project includes automated unit and widget tests covering:
- **Auth Flow**: Sign in, sign up (with redirect unauthenticated state), sign out, and error handling.
- **API Models**: JSON serialization and deserialization for `ApiUser` and `UsersResponse`.
- **Repository & Pagination**: Initial fetch (5 users), sequential page appending (pages 2 and 3), end-of-list detection, pull-to-refresh reset, and network failure states.
