# macOS Maintenance Script

A comprehensive automated maintenance script for macOS that helps clean cache files, optimize storage, and keep your system running smoothly.

## Features

-   System and Homebrew updates
-   Xcode cache cleaning
-   iOS Simulator cleanup
-   NPM/NVM cache management
-   PNPM store optimization
-   Flutter/Dart/FVM cache cleaning
-   System cache removal
-   Docker cleanup
-   Time Machine snapshot management
-   Automatic log generation

## Requirements

-   macOS (any recent version)
-   Terminal access
-   Sudo privileges for some operations

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
6. Clean NPM/NVM
7. Clean PNPM
8. Clean Flutter/Dart/FVM
9. Clean system caches
10. Clean downloads and trash
11. Clean old logs
12. Optimize storage
13. Clean Docker
14. View action log

## What Gets Cleaned

-   **System Updates**: Software update caches
-   **Development Tools**: Xcode derived data, archives, and simulator files
-   **Package Managers**: npm, pnpm cache and stores
-   **System Caches**: User library caches and logs
-   **Storage**: Old downloads (30+ days), trash, Time Machine snapshots
-   **Docker**: Unused containers, images, and volumes

## Safety

-   The script creates a detailed log file in your home directory
-   Each operation shows the amount of space freed
-   You can run individual cleaning operations instead of full maintenance
-   System restart is recommended after full maintenance

## Log Files

Log files are automatically created with timestamp:

```
~/macos_maintenance_YYYYMMDD_HHMMSS.log
```
