# Fix iOS Build Issues

## Permission Error - FIXED ✅

The permission error has been resolved:
- Created directory: `~/Library/Developer/Xcode/UserData/IB Support/Simulator Devices`
- Set proper permissions (755)
- Directory is now writable by the user

## Remaining Issue: iOS 26.2 Simulator Runtime

The build is still failing because Xcode can't find iOS 26.2 simulator runtime for Interface Builder validation.

### Solution 1: Install iOS 26.2 Simulator Runtime (Recommended)

1. Open Xcode
2. Go to **Settings → Platforms** (or **Preferences → Components** in older Xcode)
3. Find **iOS 26.2 Simulator** in the list
4. Click the download button next to it
5. Wait for download to complete
6. Try building again

### Solution 2: Use Xcode GUI to Build

Building from Xcode GUI handles Interface Builder validation better:

```bash
open ios/Runner.xcworkspace
```

Then in Xcode:
- Select your iPhone as the build target
- Press Cmd+R to build and run

### Solution 3: Check Available Runtimes

```bash
# List available simulator runtimes
xcrun simctl list runtimes

# List available SDKs
xcodebuild -showsdks
```

### Solution 4: Use a Different iOS Version (if available)

If you have other iOS SDKs installed, you might be able to force Xcode to use a different version, but this requires modifying build settings.

## Current Status

- ✅ Permissions fixed
- ✅ Pod install working
- ✅ LibSignalClient installed
- ⚠️ Interface Builder validation error (needs iOS 26.2 runtime)

The permission issue is resolved. The remaining error is about the missing iOS 26.2 simulator runtime, which needs to be installed via Xcode.
