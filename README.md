<h1 id="screenshot">Screenshots</h1>

<p align="center">
  <img src="https://github.com/user-attachments/assets/437654fa-398f-4185-b485-624a7a12cdfa" width="1000" height="600" alt="Architecture">
</p>

# dev cleaner macOS Script

A comprehensive, modular automated maintenance script for macOS that helps clean cache files, optimize storage, and keep your system running smoothly.

## Features

- **Modular Architecture**: Clean, organized code split into focused modules
- **System and Homebrew Updates**: Keep your system up to date with full `brew cleanup --prune=all` and `brew autoremove`
- **Xcode Cache Cleaning**: Remove DerivedData, Archives, DeviceSupport symbols, and simulator files
- **iOS Simulator Cleanup**: Clean simulator data and caches
- **iOS Firmware Files (IPSW) Removal**: Delete old iOS update files
- **Android Studio & Emulator**: Complete cache cleaning including Gradle
- **Node.js Ecosystem**: NPM/NVM, PNPM, Bun, Yarn (Classic & Berry), Volta, Turbo, and orphan node_modules
- **Flutter/Dart/FVM Cache**: Clean Flutter development caches
- **Expo & React Native**: Metro, Watchman, EAS CLI, and Android build artifacts
- **Dev Tools**: CocoaPods, Ruby (rbenv/RVM/gems), Python (pyenv/pip/\_\_pycache\_\_)
- **System Cache Removal**: User caches, app sandbox containers, diagnostic reports, logs
- **System Assets**: AssetsV2 / iWork Templates, iCloud CloudKit cache, Spotlight index rebuild
- **Docker Cleanup**: Remove unused containers, images, and volumes
- **Time Machine Snapshot Management**: Remove local snapshots
- **CrossOver Cleaning**: Clean CrossOver Wine bottles & caches
- **Browser Cache Cleaning**: Remove caches from Chrome, Orion, Safari
- **IDE Cache Cleaning**: Remove caches from JetBrains IDEs, VSCode, and Zed Editor
- **App Cache Cleaning**: Remove caches from Slack, Discord, Spotify, and other apps
- **DNS Cache Flush**: Reset DNS with `dscacheutil` + `mDNSResponder`
- **System Restart**: Safe restart option with countdown timer
- **Automatic Log Generation**: Detailed maintenance logs with timestamps

## Requirements

- macOS (any recent version)
- Terminal access
- Sudo privileges for some operations

## Project Structure

```
dev-cleaner-macos/
├── maintenance.sh          # Main script with interactive menu
├── lib/                    # Modular components
│   ├── colors.sh           # Color definitions for output
│   ├── helpers.sh          # Helper functions (size calc, formatting, progress)
│   ├── system-update.sh    # System and Homebrew updates
│   ├── ios-clean.sh        # iOS Simulator and IPSW cleaning
│   ├── android-clean.sh    # Android Studio, Emulator & Gradle
│   ├── node-clean.sh       # NPM, Bun, PNPM, Yarn, Volta, Turbo, node_modules
│   ├── flutter-clean.sh    # Flutter/Dart/FVM cleaning
│   ├── system-clean.sh     # System caches, Xcode DerivedData, containers, DNS
│   ├── docker-clean.sh     # Docker cleanup
│   ├── crossover-clean.sh  # CrossOver Wine bottles & caches
│   ├── expo-clean.sh       # Expo & React Native caches
│   ├── devtools-clean.sh   # Homebrew, CocoaPods, Ruby, Python
│   ├── assets-clean.sh     # AssetsV2, iWork templates, iCloud, Spotlight
│   ├── storage-optimize.sh # Storage optimization
│   ├── browser-clean.sh    # Browser caches (Chrome, Safari, Orion)
│   ├── ide-clean.sh        # IDE caches (JetBrains, VSCode, Zed Editor)
│   ├── apps-clean.sh       # App caches (Slack, Discord, Spotify, and others)
│   └── restart-macos.sh    # System restart function
└── README.md               # This file
```

## Installation

```bash
git clone https://github.com/Victor-Zarzar/dev-cleaner-macOS
cd dev-cleaner-macOS
chmod +x maintenance.sh
./maintenance.sh
```

The script will display an interactive menu with the following options:

```
1)  Run complete maintenance
2)  Update system and Homebrew
3)  Clean update cache
4)  Clean system (caches, logs, Xcode, DNS)
5)  Clean system assets (AssetsV2, iCloud, Spotlight)
6)  Optimize storage
7)  Clean iOS simulator
8)  Clean iOS firmwares (IPSW)
9)  Clean Android Studio & Emulator
10) Clean Node.js (NPM, PNPM, Bun, Yarn, Volta, Turbo)
11) Clean Flutter / Dart / FVM
12) Clean Expo & React Native
13) Clean dev tools (Homebrew, CocoaPods, Ruby, Python)
14) Clean Docker
15) Clean CrossOver cache
16) Clean browser caches
17) Clean IDE caches (JetBrains, VSCode, Zed Editor)
18) Clean app caches (Slack, Discord, Spotify...)
19) View action log
20) Restart macOS
0)  Exit
```

## What Gets Cleaned

### System

- **System Caches**: User library caches, app sandbox containers (Caches/Logs only)
- **Diagnostic Reports**: `~/Library/Logs`, `/Library/Logs/DiagnosticReports`
- **Xcode DerivedData**: Build artifacts (5–20 GB), old DeviceSupport symbols
- **Xcode Archives**: Optional removal with confirmation
- **DNS Cache**: `dscacheutil` flush + `mDNSResponder` restart
- **AssetsV2 / iWork Templates**: Pages, Numbers, Keynote templates (~800 MB, re-downloaded on demand)
- **iCloud CloudKit Cache**: Local CloudKit cache rebuild automatically
- **Spotlight Index**: Optional full rebuild

### Development Tools

- **Xcode**: DerivedData, Archives, Simulator caches, template cache
- **Android Studio & Emulator**: AVD caches, build caches, IDE caches, logs
- **Gradle**: Complete cache removal, old wrappers, daemon logs
- **iOS Simulator**: Simulator data and caches (1–5 GB)
- **Homebrew**: `brew upgrade`, `cleanup --prune=all`, `autoremove`, download cache
- **CocoaPods**: Download cache + spec repos (with confirmation)
- **Ruby**: rbenv/RVM old versions, gem download cache
- **Python**: pyenv old versions, pip cache, `__pycache__` in projects

### Mobile Development

- **iOS Firmwares**: IPSW files downloaded by Finder/iTunes (3–11 GB each)
- **Flutter/Dart/FVM**: Development tool caches and pub cache
- **Expo/React Native**: Metro cache, Watchman, EAS CLI, Android build artifacts

### Node.js Ecosystem

- **NPM/NVM**: npm cache clean
- **Bun**: Install cache, logs, temporary files
- **PNPM**: Store prune
- **Yarn Classic**: `yarn cache clean`
- **Yarn Berry**: Global Berry cache
- **Volta**: Temporary download files
- **Turbo**: Global `~/.turbo` cache + project caches (with confirmation)
- **Orphan node_modules**: Scans `~/Projects` for `node_modules` older than 30 days (with confirmation)

### Browsers

- **Google Chrome**: Profile caches, GPUCache, Code Cache, and media cache
- **Orion Browser**: Browser cache and offline data
- **Safari**: Cache database and browser cache directories

### IDEs

- **JetBrains IDEs**: Caches for IntelliJ IDEA, WebStorm, Android Studio, PyCharm, GoLand, CLion, DataGrip, RubyMine, and Rider
- **Visual Studio Code**: Cache, CachedData, CachedExtensions, and Code Cache
- **Zed Editor**: Cache directory

### Apps

- **Slack**: Application cache and service worker data
- **Discord**: Cache, Code Cache, and GPUCache
- **Spotify**: Browser cache, data, and offline storage
- **Other apps**: Generic user `~/Library/Caches` cleanup for remaining applications

### Package Managers

- **Gradle**: Full cache removal with wrapper optimization

### Other

- **Storage**: Old downloads (30+ days), trash, Time Machine snapshots, Photos cache
- **Docker**: Unused containers, images, volumes, build cache
- **CrossOver**: Wine bottles and caches

## System Restart Feature

The script includes a safe system restart option:

- **Confirmation required**: Prevents accidental restarts
- **5-second countdown**: Time to cancel with Ctrl+C
- **Logged action**: Restart is recorded in maintenance log
- **Works independently**: Can be used after any maintenance operation

## Entrypoints

Functions are grouped into entrypoints for convenience in `run_full_maintenance()` and the menu:

| Entrypoint               | Includes                                                               |
| ------------------------ | ---------------------------------------------------------------------- |
| `clean_system_clean`     | system caches, downloads, logs, Xcode DerivedData, app containers, DNS |
| `clean_system_assets`    | AssetsV2, Xcode templates, iCloud cache, Spotlight                     |
| `clean_system_nodejs`    | NPM, PNPM, Bun, Yarn, Volta, Turbo, node_modules                       |
| `clean_system_devtools`  | Homebrew, CocoaPods, Ruby, Python                                      |
| `cleanup_browser_caches` | Chrome, Firefox, Safari, Brave, Arc, Edge                              |
| `cleanup_ide_caches`     | JetBrains IDEs, VSCode, Zed Editor                                     |
| `cleanup_app_caches`     | Slack, Discord, Spotify, and other app caches                          |

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
4. Add `source "$LIB_DIR/module-name.sh"` in `maintenance.sh`
5. Call functions in `run_full_maintenance()` or add to an entrypoint

## Safety

- The script creates a detailed log file in your home directory
- Each operation shows the amount of space freed
- You can run individual cleaning operations instead of full maintenance
- Smart handling of system directories with proper permission checks
- All `get_folder_size` calls use `${size:-0}` to prevent integer expression errors
- Destructive operations (archives, spec repos, node_modules, old language versions) always ask for confirmation
- System restart requires confirmation and provides countdown timer

## Log Files

Log files are automatically created with timestamp:

```
~/dev_cleaner_macOS_YYYYMMDD_HHMMSS.log
```

View the log from the menu (option 19) or manually:

```bash
cat ~/dev_cleaner_macOS_*.log
```

## Space Savings

Typical space savings after running full maintenance:

| Area                                 | Savings          |
| ------------------------------------ | ---------------- |
| Xcode DerivedData & caches           | 5–20 GB          |
| iOS Simulator                        | 1–5 GB           |
| Android Studio & Gradle              | 5–8 GB           |
| iOS Firmwares (IPSW)                 | 3–11 GB per file |
| System caches & logs                 | 500 MB – 5 GB    |
| Docker                               | 1–10 GB          |
| Node.js ecosystem                    | 500 MB – 3 GB    |
| AssetsV2 / iWork templates           | ~800 MB          |
| Dev tools (Ruby, Python, CocoaPods)  | 500 MB – 2 GB    |
| Browser caches                       | 200 MB – 2 GB    |
| IDE caches (JetBrains, VSCode, Zed)  | 500 MB – 3 GB    |
| App caches (Slack, Discord, Spotify) | 200 MB – 1 GB    |
| **Total**                            | **15–70+ GB**    |

## Tips

- Run option **1** (Complete maintenance) monthly for optimal performance
- Use individual options for targeted cleaning
- Check the log file if any cleaning fails
- Some operations may require administrator password
- Gradle cache will be automatically rebuilt on next build
- Use option **20** to safely restart your Mac after maintenance
- System restart recommended after full maintenance

## Troubleshooting

If you encounter issues:

1. Check the log file for detailed error messages
2. Ensure you have a stable internet connection for updates
3. Make sure you have enough permissions (some operations require sudo)
4. Run individual cleaning operations to isolate problems
5. Some paths may not exist if tools aren't installed (this is normal)

### Common Issues

**Permission errors:** Some operations may request administrator password.

**Gradle rebuilding:** After cleaning Gradle cache, first build will take longer as cache rebuilds.

**Restart requires sudo:** System restart operation requires administrator privileges.

**Browser/App caches:** Apps should be closed before cleaning their caches to avoid conflicts.

**View detailed errors:**

```bash
cat ~/dev_cleaner_macOS_*.log
```

## Advantages of Modular Architecture

- **Maintainability**: Each module has a specific responsibility
- **Readability**: Smaller, focused files
- **Reusability**: Modules can be used independently
- **Scalability**: Easy to add new cleaning functions
- **Debugging**: Easier to find and fix issues
- **Safety**: Isolated functions reduce risk of errors

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## Author

Victor Zarzar

---

**Note**: This script is designed for personal use. Review the code before running and adjust according to your needs. Always ensure you have backups of important data before running maintenance scripts.
