# macOS Maintenance Script

A comprehensive automated maintenance script for macOS that helps clean cache files, optimize storage, and keep your system running smoothly.

## Features

- System and Homebrew updates
- Xcode cache cleaning
- iOS Simulator cleanup
- Android Studio & Emulator cache cleaning
- iOS firmware files (IPSW) removal
- NPM/NVM cache management
- PNPM store optimization
- Flutter/Dart/FVM cache cleaning
- System cache removal
- Docker cleanup
- Time Machine snapshot management
- Automatic log generation

## Requirements

- macOS (any recent version)
- Terminal access
- Sudo privileges for some operations

## Installation

Clone the repository:
```bash
git clone https://github.com/Victor-Zarzar/script-maintenance-macOS
```

Navigate to the directory:
```bash
cd script-maintenance-macOS
```

Make the script executable:
```bash
chmod +x macOS_maintenance.sh
```

## Usage

Run the script:
```bash
./macOS_maintenance.sh
```

The script will display an interactive menu with the following options:

1. Run complete maintenance
2. Update system and Homebrew
3. Clean update cache
4. Clean Xcode cache
5. Clean iOS simulator
6. Clean Android Studio & Emulator
7. Clean iOS firmwares (IPSW)
8. Clean NPM/NVM
9. Clean PNPM
10. Clean Flutter/Dart/FVM
11. Clean system caches
12. Clean downloads and trash
13. Clean old logs
14. Optimize storage
15. Clean Docker
16. View action log

## What Gets Cleaned

### Development Tools
- **Xcode**: Derived data, archives, and simulator files
- **Android Studio & Emulator**: AVD caches, build caches, IDE caches, and logs (5-8 GB typically) ⭐ NEW
- **iOS Simulator**: Simulator data and caches

### Mobile Development
- **iOS Firmwares**: IPSW files downloaded by Finder/iTunes (3-8 GB each)
- **Flutter/Dart/FVM**: Development tool caches
- **Android**: Emulator caches, build caches, and Android Studio logs ⭐ NEW

### Package Managers
- **NPM/NVM**: Node package manager caches
- **PNPM**: Store and cache optimization
- **Gradle**: Detection and notification (manual cleaning recommended) ⭐ NEW

### System Maintenance
- **System Updates**: Software update caches
- **System Caches**: User library caches and logs
- **Storage**: Old downloads (30+ days), trash, Time Machine snapshots
- **Docker**: Unused containers, images, and volumes

## Android Studio Cleaning Details

The script cleans the following Android-related directories:
- `~/.android/avd/*/cache` - Individual AVD cache directories
- `~/.android/cache` - General Android cache
- `~/.android/build-cache` - Android build cache
- `~/Library/Caches/AndroidStudio*` - Android Studio cache
- `~/Library/Application Support/Google/AndroidStudio*/caches` - IDE caches
- `~/Library/Logs/Google/AndroidStudio*` - Android Studio logs

**Note**: Gradle caches are detected but not automatically cleaned to prevent breaking active projects. The script will notify you if Gradle cache is found and suggest running `./gradlew cleanBuildCache` in your projects.

## Safety

- The script creates a detailed log file in your home directory
- Each operation shows the amount of space freed
- You can run individual cleaning operations instead of full maintenance
- Smart handling of system directories with proper permission checks
- Gradle cache requires manual cleaning to prevent project issues
- System restart is recommended after full maintenance

## Log Files

Log files are automatically created with timestamp:
```
~/macos_maintenance_YYYYMMDD_HHMMSS.log
```

## Space Savings

Typical space savings after running full maintenance:

- Xcode caches: 5-20 GB
- iOS Simulator: 1-5 GB
- Android Studio & Emulator: 5-8 GB
- iOS Firmwares (IPSW): 3-11 GB per file
- System caches: 500 MB - 5 GB
- Docker: 1-10 GB
- **Total: 15-60+ GB** depending on usage