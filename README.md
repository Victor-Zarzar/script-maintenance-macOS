# macOS Maintenance Script

A comprehensive, modular automated maintenance script for macOS that helps clean cache files, optimize storage, and keep your system running smoothly.

## Features

- **Modular Architecture**: Clean, organized code split into focused modules
- **System and Homebrew Updates**: Keep your system up to date
- **Xcode Cache Cleaning**: Remove DerivedData, archives, and simulator files
- **iOS Simulator Cleanup**: Clean simulator data and caches
- **iOS Firmware Files (IPSW) Removal**: Delete old iOS update files
- **Android Studio & Emulator**: Complete cache cleaning including Gradle
- **NPM/NVM Cache Management**: Clean Node.js package manager caches
- **Bun Store Optimization**: Clean Bun cache and logs
- **PNPM Cache Management**: Prune unused packages
- **Flutter/Dart/FVM Cache**: Clean Flutter development caches
- **System Cache Removal**: Clean user library caches and logs
- **Docker Cleanup**: Remove unused containers, images, and volumes
- **Time Machine Snapshot Management**: Remove local snapshots
- **Automatic Log Generation**: Detailed maintenance logs with timestamps

## Requirements

- macOS (any recent version)
- Terminal access
- Sudo privileges for some operations

## Project Structure

```
maintenance-macos/
├── maintenance.sh        # Main script with interactive menu
├── lib/                  # Modular components
│   ├── colors.sh         # Color definitions for output
│   ├── helpers.sh        # Helper functions (size calc, formatting, progress)
│   ├── system-update.sh  # System and Homebrew updates
│   ├── xcode-clean.sh    # Xcode cache cleaning
│   ├── ios-clean.sh      # iOS Simulator and IPSW cleaning
│   ├── android-clean.sh  # Android Studio, Emulator & Gradle
│   ├── node-clean.sh     # NPM, Bun, PNPM cleaning
│   ├── flutter-clean.sh  # Flutter/Dart/FVM cleaning
│   ├── system-clean.sh   # System caches, downloads, logs
│   ├── docker-clean.sh   # Docker cleanup
│   └── storage-optimize.sh # Storage optimization
└── README.md             # This file
```

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
chmod +x maintenance.sh
```

## Usage

Run the script:

```bash
./maintenance.sh
```

The script will display an interactive menu with the following options:

1. Run complete maintenance
2. Update system and Homebrew
3. Clean update cache
4. Clean Xcode cache
5. Clean iOS simulator
6. Clean iOS firmwares (IPSW)
7. Clean Android Studio & Emulator
8. Clean NPM/NVM
9. Clean Bun
10. Clean PNPM
11. Clean Flutter/Dart/FVM
12. Clean system caches
13. Clean downloads and trash
14. Clean old logs
15. Optimize storage
16. Clean Docker
17. View action log
18. Exit

## What Gets Cleaned

### Development Tools

- **Xcode**: DerivedData (5-20 GB), Archives, Simulator caches
- **Android Studio & Emulator**: AVD caches, build caches, IDE caches, logs (5-8 GB)
- **Gradle**: Complete cache removal, old wrappers, daemon logs
- **iOS Simulator**: Simulator data and caches (1-5 GB)

### Mobile Development

- **iOS Firmwares**: IPSW files downloaded by Finder/iTunes (3-11 GB each)
- **Flutter/Dart/FVM**: Development tool caches and pub cache
- **Android**: Emulator caches, build caches, Android Studio logs

### Package Managers

- **NPM/NVM**: Node package manager caches
- **Bun**: Cache, logs, and temporary files
- **PNPM**: Store pruning
- **Gradle**: Full cache removal with wrapper optimization

### System Maintenance

- **System Updates**: Software update caches
- **System Caches**: User library caches and logs (500 MB - 5 GB)
- **Storage**: Old downloads (30+ days), trash, Time Machine snapshots
- **Docker**: Unused containers, images, volumes (1-10 GB)

## Android Studio & Gradle Cleaning Details

The script performs comprehensive Android cleaning:

### Android Studio & Emulator

- `~/.android/avd/*/cache` - Individual AVD cache directories
- `~/.android/cache` - General Android cache
- `~/.android/build-cache` - Android build cache
- `~/Library/Caches/AndroidStudio*` - Android Studio cache
- `~/Library/Application Support/Google/AndroidStudio*/caches` - IDE caches
- `~/Library/Logs/Google/AndroidStudio*` - Android Studio logs

### Gradle (Complete Removal)

- `~/.gradle/caches/*` - Entire Gradle cache (will be rebuilt on next build)
- `~/.gradle/wrapper/dists/*` - Keeps only latest wrapper version
- `~/.gradle/daemon/*.log` - Old daemon logs (7+ days)
- `~/Projects/**/.gradle` - Project-level build caches (with confirmation)

**Note**: Gradle cache is completely removed, which is safe as it will be automatically rebuilt on your next build. This can free up several GB of space.

## Customization

### Adding New Cleaning Functions

1. Identify the correct module in `lib/`
2. Add your cleaning function
3. Update `maintenance.sh` to call your function
4. Add option to menu if needed

Example in `lib/node-clean.sh`:

```bash
clean_your_tool() {
    print_section "Cleaning Your Tool"

    if command -v yourtool &> /dev/null; then

        print_success "Tool cleaned"
    else
        print_info "Tool not found"
    fi

    log_action "Your tool cleaned"
}
```

### Creating New Modules

1. Create file in `lib/module-name.sh`
2. Add shebang and section comment
3. Create cleaning functions
4. Add source in `maintenance.sh`
5. Call functions in `run_full_maintenance()`

## Safety

- The script creates a detailed log file in your home directory
- Each operation shows the amount of space freed
- You can run individual cleaning operations instead of full maintenance
- Smart handling of system directories with proper permission checks
- Gradle cache is completely removed (safe, will rebuild automatically)
- System restart is recommended after full maintenance

## Log Files

Log files are automatically created with timestamp:

```
~/macos_maintenance_YYYYMMDD_HHMMSS.log
```

View the log from the menu (option 17) or manually:

```bash
cat ~/macos_maintenance_*.log
```

## Space Savings

Typical space savings after running full maintenance:

- **Xcode caches**: 5-20 GB
- **iOS Simulator**: 1-5 GB
- **Android Studio & Emulator**: 5-8 GB
- **Gradle cache**: 2-5 GB
- **iOS Firmwares (IPSW)**: 3-11 GB per file
- **System caches**: 500 MB - 5 GB
- **Docker**: 1-10 GB
- **Bun/NPM/PNPM**: 500 MB - 2 GB

**Total**: 15-60+ GB depending on usage

## Tips

- Run option **1** (Complete maintenance) monthly for optimal performance
- Use individual options for targeted cleaning
- Check the log file if any cleaning fails
- Some operations may require administrator password
- Gradle cache will be automatically rebuilt on next build
- System restart recommended after full maintenance

## Troubleshooting

If you encounter issues:

1. Check the log file for detailed error messages
2. Ensure you have a stable internet connection for updates
3. Make sure you have enough permissions (some operations require sudo)
4. Run individual cleaning operations to isolate problems
5. Some paths may not exist if tools aren't installed (this is normal)

### Common Issues

**Permission errors:**
Some operations may request administrator password.

**Gradle rebuilding:**
After cleaning Gradle cache, first build will take longer as cache rebuilds.

**View detailed errors:**

```bash
cat ~/macos_maintenance_*.log
```

## Advantages of Modular Architecture

- **Maintainability**: Each module has a specific responsibility
- **Readability**: Smaller, focused files
- **Reusability**: Modules can be used independently
- **Scalability**: Easy to add new cleaning functions
- **Debugging**: Easier to find and fix issues

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## Author

Victor Zarzar

---

**Note**: This script is designed for personal use. Review the code before running and adjust according to your needs. Always ensure you have backups of important data before running maintenance scripts.
