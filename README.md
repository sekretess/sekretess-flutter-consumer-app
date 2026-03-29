# Sekretess Consumer Flutter App

Flutter version of the Sekretess Consumer Android application.

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── error/
│   ├── network/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    ├── providers/
    └── theme/
```

## Features

- Authentication (Login/Signup)
- Real-time messaging via WebSocket
- Signal Protocol encryption
- Business subscription management
- Message history
- Profile management
- Push notifications (Firebase)

## Getting Started

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
flutter run
```

## Build Configurations

- Development: `flutter run --dart-define=ENV=dev`
- Staging: `flutter run --dart-define=ENV=staging`
- Production: `flutter run --dart-define=ENV=prod`
- Google Play: `flutter build appbundle --release`
