# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PhotoDIY is a photo processing iOS application that provides image editing capabilities including filters, cropping, text overlay, drawing, and social sharing. The project consists of two main implementations:

- **OC/**: Legacy Objective-C implementation (currently active)
- **Swift/**: New Swift rewrite (in development on `swift` branch)

## Build Commands

### Swift Version (Swift/Photofy/) - Recommended
```bash
# Build and run the modern Swift version
cd Swift/Photofy
open Photofy.xcodeproj

# Build using xcodebuild (optional)
xcodebuild -project Photofy.xcodeproj -scheme Photofy -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run tests
xcodebuild -project Photofy.xcodeproj -scheme Photofy -destination 'platform=iOS Simulator,name=iPhone 17' test
```

### Objective-C Version (OC/) - Legacy
```bash
# Install CocoaPods dependencies
cd OC && pod install

# Build and run
open PhotoDIY.xcworkspace
# Use Xcode to build and run the project
```

### Icon and Launch Image Generation
```bash
# Install required tools
brew install imagemagick && sudo npm i -g ticons

# Generate icons
ticons icons ./PhotoDIY.png --output-dir ~/Pictures/icons --alloy --platforms iphone,ipad

# Generate launch screens
ticons splashes ./Launch.png --output-dir ~/Pictures/launch --alloy --platforms iphone,ipad
```

### Simulator Build for Facebook Review
```bash
# Create simulator build from DerivedData
ditto -ck --sequesterRsrc --keepParent `ls -1 -d -t ~/Library/Developer/Xcode/DerivedData/*/Build/Products/*-iphonesimulator/PhotoDIY.app | head -n 1` ~/Desktop/PhotoDIY.zip

# Verify with ios-sim
ios-sim --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6s launch ~/Desktop/PhotoDIY.app
```

## Architecture

### Swift Version (Photofy) - Modern Architecture
- **Language**: Swift 5.9+
- **Minimum iOS**: 15.0+
- **Architecture**: MVVM + Coordinator Pattern
- **UI Framework**: SwiftUI + UIKit (hybrid)
- **Image Processing**: Core Image + Metal Performance Shaders
- **Reactive Programming**: Combine Framework
- **Dependency Injection**: Custom DI container
- **Photo Library**: PhotoKit for modern photo access
- **Sharing**: Native UIActivityViewController + custom activities
- **Persistence**: Core Data with CloudKit sync
- **Testing**: XCTest with UI Tests

### Objective-C Version (OC/) - Legacy Architecture
- **Image Processing**: GPUImage framework for real-time filters and effects
- **UI Components**: MBProgressHUD, FCAlertView, FDStackView, FXBlurView
- **Image Loading**: SDWebImage for async image loading and caching
- **Social Sharing**: UMengUShare SDK for WeChat, Weibo, QQ, Twitter, Instagram
- **Monetization**: Google Mobile Ads SDK for advertising
- **Target iOS**: 7.0+ (legacy support)

### Key Components
- **PhotoTools/**: Core photo processing and camera functionality
- **ContentView/**: Main editing interface and UI components
- **DataManager/**: Data persistence and app state management
- **ThirdParts/**: Custom third-party integrations and modifications
- **Assets.xcassets/**: Organized image assets by feature (FilterView, ToolBar, Drawboard, etc.)

### Social Integration
The app integrates with multiple social platforms:
- WeChat (微信): `wxe9ee15bc76746188`
- Facebook: Test (`326136004438567`) and Production (`325600794492088`) apps
- Twitter, Instagram, QQ, Sina Weibo via UMengUShare

### Localization
Supports multiple languages with `.lproj` directories:
- Chinese (Simplified/Traditional)
- English
- Korean
- Japanese
- Arabic
- German

## Development Workflow

### Working with Swift Branch
The project is transitioning to Swift. The `swift` branch contains the new implementation. Use git to switch between versions:

```bash
# Switch to Swift implementation
git checkout swift

# Switch back to Objective-C
git checkout main
```

### CocoaPods Management
Always use the `.xcworkspace` file when opening the project in Xcode, not the `.xcodeproj` file, due to CocoaPods integration.

### Key Dependencies
- GPUImage 0.1.7: Core image processing
- UMengUShare 6.2.2: Social sharing platform
- Google-Mobile-Ads-SDK 7.28.0: Advertising integration
- SDWebImage 3.8.1: Image loading and caching

## App Store Information
- **App Store URL**: https://itunes.apple.com/app/id1133036606
- **Support Website**: http://app.wodedata.com/myapp/photodiy.html
- **Current Version**: 1.1 (includes iPhone X compatibility, custom font downloading, push notifications)