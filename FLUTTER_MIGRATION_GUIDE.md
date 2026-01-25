# Flutter Migration Guide

This document outlines the migration from Android Java to Flutter.

## Project Structure

The Flutter app follows Clean Architecture principles:

```
lib/
├── core/              # Core functionality (DI, network, constants, utils)
├── data/              # Data layer (models, repositories, datasources)
├── domain/            # Domain layer (entities, use cases, repository interfaces)
└── presentation/     # UI layer (pages, widgets, providers)
```

## Key Conversions

### 1. Dependency Injection
- **Android**: Static `SekretessDependencyProvider`
- **Flutter**: `get_it` + `injectable` for proper DI

### 2. State Management
- **Android**: LiveData, MutableLiveData
- **Flutter**: `flutter_riverpod` for reactive state management

### 3. Database
- **Android**: Room Database
- **Flutter**: `drift` (SQLite) or `hive` (NoSQL)

### 4. Networking
- **Android**: OkHttp, Retrofit
- **Flutter**: `dio` for HTTP, `web_socket_channel` for WebSocket

### 5. Local Storage
- **Android**: SharedPreferences, Room
- **Flutter**: `shared_preferences`, `hive`, or `drift`

### 6. JSON Serialization
- **Android**: Jackson
- **Flutter**: `json_serializable` with code generation

## Remaining Tasks

### High Priority
1. ✅ Project structure created
2. ✅ Basic models converted
3. ✅ API client setup
4. ✅ Auth repository
5. ⏳ Complete all DTOs conversion
6. ⏳ Implement WebSocket service
7. ⏳ Signal Protocol encryption (need Flutter equivalent)
8. ⏳ Database implementation (Drift/Hive)
9. ⏳ Complete UI screens
10. ⏳ Firebase messaging setup

### Medium Priority
1. ⏳ Message repository
2. ⏳ Business repository
3. ⏳ Use cases (domain layer)
4. ⏳ State providers (Riverpod)
5. ⏳ Error handling
6. ⏳ Loading states

### Low Priority
1. ⏳ Unit tests
2. ⏳ Widget tests
3. ⏳ Integration tests
4. ⏳ Documentation
5. ⏳ CI/CD setup

## Signal Protocol Challenge

The Android app uses `libsignal-client` (Java) for encryption. For Flutter, you have options:

1. **Use Platform Channels**: Call native Android/iOS Signal libraries
2. **Find Flutter Alternative**: Look for Dart implementations
3. **FFI (Foreign Function Interface)**: Call C/C++ Signal libraries

Recommended approach: Use platform channels to call the existing Signal libraries.

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Run `flutter pub run build_runner build` to generate code
3. Complete remaining model conversions
4. Implement WebSocket service
5. Set up database
6. Complete UI screens
7. Test and iterate

## Notes

- The Flutter app uses modern patterns (Riverpod, Clean Architecture)
- All network calls are async/await (no ExecutorService)
- State management is reactive and testable
- Code generation is used for JSON serialization and DI
