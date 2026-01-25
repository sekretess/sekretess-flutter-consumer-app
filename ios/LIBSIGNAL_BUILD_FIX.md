# LibSignalClient Build Fix

## Error: PhaseScriptExecution failed

The LibSignalClient pod adds script phases that download and extract prebuilt binaries. If these fail, check:

### 1. Check Rust Installation (if building from source)

LibSignalClient may need Rust to build from source if prebuilt binaries aren't available:

```bash
# Check if Rust is installed
rustc --version
cargo --version

# If not installed, install Rust:
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 2. Check Network Access

The script tries to download prebuilt binaries. Ensure you have internet access and can reach:
- GitHub (for downloading libsignal-ffi binaries)
- The checksum matches: `fb5a199f21df1e088b99f92e5d43102cf7abecd0f95b5a64fad1a3ae300045a2`

### 3. Check Cache Directory Permissions

```bash
# Ensure cache directory exists and is writable
mkdir -p ~/Library/Caches/CocoaPods/libsignal-ffi
chmod 755 ~/Library/Caches/CocoaPods/libsignal-ffi
```

### 4. Clean and Rebuild

```bash
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Caches/CocoaPods/libsignal-ffi
pod install
```

### 5. Check Xcode Build Log

In Xcode:
1. Open the project
2. Go to **View → Navigators → Show Report Navigator**
3. Find the failed build
4. Expand the "PhaseScriptExecution" entry
5. Check the actual error message

### 6. Alternative: Use Prebuilt Binaries

If the download fails, you can manually download and place the prebuilt binary in the cache directory.

### Current Configuration

- **LibSignalClient version**: v0.83.0
- **Checksum**: fb5a199f21df1e088b99f92e5d43102cf7abecd0f95b5a64fad1a3ae300045a2
- **Platform**: iOS 15.0+
