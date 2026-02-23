# Building the iOS project

## Overview
This project uses CocoaPods for iOS dependencies. If you see errors like:
- "The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation."
- SSL errors during `pod install` / `pod repo update`

Use the script below to clean and reinstall pods safely.

## One-time setup
- Ensure you have recent tooling:
  - Xcode 15+ (or project-required version)
  - Ruby and CocoaPods
    - If needed: `brew install ruby` then `gem install cocoapods`

## Fixing CocoaPods sync errors
From the repo root (or `ios/` if your Podfile is there), run:

