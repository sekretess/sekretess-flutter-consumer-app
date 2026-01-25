# iOS Build Fix for Interface Builder Validation Error

## Problem
When building from Flutter CLI/Android Studio, you may encounter:
```
Error: Failed to find a suitable device for the type IBSimDeviceTypeiPad3x
```

This is a known Xcode 15+ issue where Interface Builder tries to validate storyboards against simulator runtimes that don't exist.

## Solution 1: Build from Xcode (Recommended)

The most reliable solution is to build directly from Xcode:

```bash
# Open the project
open ios/Runner.xcworkspace
```

Then in Xcode:
1. Select your iPhone as the build target (top toolbar)
2. Press **Cmd+R** to build and run
3. Xcode handles Interface Builder validation better when building from GUI

## Solution 2: Use the Build Script

I've created a build script that sets environment variables:

```bash
cd /Users/elnur/StudioProjects/consumer_flutter_app
./ios/build_without_ib_validation.sh
```

## Solution 3: Set Environment Variables Manually

Before building, set these environment variables:

```bash
export IBSC_DISABLE_INTERFACE_BUILDER_VALIDATION=YES
export XCODE_SKIP_INTERFACE_BUILDER_VALIDATION=YES
flutter build ios --no-codesign --release
```

## Solution 4: Update Xcode

1. Open Xcode
2. Go to **Settings → Platforms**
3. Download/Install the iOS 26.2 simulator runtime (if available)
4. This will allow Xcode to validate against the required simulator

## Solution 5: Modify Build Settings in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project → **Runner** target
3. Go to **Build Settings** tab
4. Search for "Validate"
5. Set **Validate Development Asset Paths** to **No**
6. Set **Validate Product** to **No**

## Note

The build settings in `Flutter/Release.xcconfig` and `Flutter/Debug.xcconfig` have been updated to disable validation, but Xcode's Interface Builder validation can still occur at a lower level. Building from Xcode GUI is the most reliable workaround.
