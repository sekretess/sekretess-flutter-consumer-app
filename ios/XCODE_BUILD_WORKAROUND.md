# Xcode Interface Builder Validation Error - Workaround

## The Problem

When building the iOS app, you may encounter this error:
```
Failed to find a suitable device for the type IBSimDeviceTypeiPad3x (com.apple.dt.Xcode.IBSimDeviceType.iPad-3x) with runtime iOS 26.2
```

This is a known Xcode 15+ issue where Interface Builder tries to validate storyboards/assets against simulator runtimes that may not exist.

## Solution 1: Install iOS 26.2 Simulator Runtime (Recommended)

1. Open Xcode
2. Go to **Settings → Platforms** (or **Preferences → Components** in older Xcode)
3. Download and install **iOS 26.2 Simulator Runtime**
4. Wait for the download to complete
5. Try building again

## Solution 2: Use a Different Build Configuration

If Solution 1 doesn't work, try building with a specific SDK version:

```bash
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build \
  build
```

## Solution 3: Build from Xcode GUI

1. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode:
   - Select **Product → Destination → Your iPhone** (physical device)
   - Press **Cmd+R** to build and run
   - Xcode GUI handles validation better than command line

## Solution 4: Clean Build Folder

Sometimes cleaning helps:

```bash
cd ios
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
flutter clean
flutter pub get
pod install
```

## What Has Been Configured

The following build settings have been added to help with this issue:

- `VALIDATE_DEVELOPMENT_ASSET_PATHS = NO`
- `VALIDATE_PRODUCT = NO`
- `IBSC_DISABLE_INTERFACE_BUILDER_VALIDATION = YES`
- `ASSETCATALOG_FILTER_FOR_DEVICE_MODEL = ""`
- `ASSETCATALOG_FILTER_FOR_DEVICE_OS_VERSION = ""`
- `TARGETED_DEVICE_FAMILY = "1"` (iPhone only, no iPad)

## Note

This is a limitation of Xcode's Interface Builder validation system, not a Flutter issue. The validation happens at a very low level and can't always be bypassed with build settings.
