#!/bin/bash

# ============================================
# macOS Maintenance Script
# Main Entry Point
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

source "$LIB_DIR/colors.sh"
source "$LIB_DIR/helpers.sh"
source "$LIB_DIR/system-update.sh"
source "$LIB_DIR/ios-clean.sh"
source "$LIB_DIR/android-clean.sh"
source "$LIB_DIR/node-clean.sh"
source "$LIB_DIR/flutter-clean.sh"
source "$LIB_DIR/system-clean.sh"
source "$LIB_DIR/docker-clean.sh"
source "$LIB_DIR/storage-optimize.sh"
source "$LIB_DIR/restart-macos.sh"
source "$LIB_DIR/crossover-clean.sh"
source "$LIB_DIR/expo-clean.sh"
source "$LIB_DIR/devtools-clean.sh"
source "$LIB_DIR/assets-clean.sh"

LOG_FILE="$HOME/macos_maintenance_$(date +%Y%m%d_%H%M%S).log"
TOTAL_CLEANED=0

# ============================================
# Main Menu
# ============================================

show_menu() {
    clear
    print_header
    echo -e "${YELLOW}Current free space: $(get_disk_usage)${NC}"
    echo ""
    echo "1)  Run complete maintenance"
    echo "2)  Update system and Homebrew"
    echo "3)  Clean update cache"
    echo "4)  Clean system (caches, logs, Xcode, DNS)"
    echo "5)  Clean system assets (AssetsV2, iCloud, Spotlight)"
    echo "6)  Optimize storage"
    echo "7)  Clean iOS simulator"
    echo "8)  Clean iOS firmwares (IPSW)"
    echo "9)  Clean Android Studio & Emulator"
    echo "10) Clean Node.js (NPM, PNPM, Bun, Yarn, Volta, Turbo)"
    echo "11) Clean Flutter / Dart / FVM"
    echo "12) Clean Expo & React Native"
    echo "13) Clean dev tools (Homebrew, CocoaPods, Ruby, Python)"
    echo "14) Clean Docker"
    echo "15) Clean CrossOver cache"
    echo "16) View action log"
    echo "17) Restart macOS"
    echo "0)  Exit"
    echo ""
    echo -n "Choose an option: "
}

run_full_maintenance() {
    local initial_space=$(get_disk_usage)

    print_header
    echo -e "${YELLOW}Initial free space: $initial_space${NC}\n"

    update_system
    clean_software_update_cache
    clean_system_clean
    clean_system_assets
    clean_ios_simulator
    clean_ios_ipsw
    clean_android_studio
    clean_system_nodejs
    clean_flutter_dart
    clean_expo_react_native
    clean_system_devtools
    optimize_storage
    clean_docker
    clean_crossover
    restart_macos

    local final_space=$(get_disk_usage)

    echo ""
    print_section "Maintenance Summary"
    echo -e "${GREEN}Initial free space:${NC} $initial_space"
    echo -e "${GREEN}Final free space:${NC}   $final_space"
    echo -e "${GREEN}Total cleaned:${NC}      $(format_bytes $((TOTAL_CLEANED * 1024)))"
    echo ""
    print_success "Maintenance complete!"
    print_warning "System restart recommended"
    echo ""

    log_action "Complete maintenance executed - Total: $(format_bytes $((TOTAL_CLEANED * 1024)))"
}

# ============================================
# Main Loop
# ============================================

main() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is for macOS only!"
        exit 1
    fi

    touch "$LOG_FILE"
    log_action "Starting maintenance script"

    while true; do
        show_menu
        read -r option
        case $option in
            1)  run_full_maintenance ;;
            2)  update_system ;;
            3)  clean_software_update_cache ;;
            4)  clean_system_clean ;;
            5)  clean_system_assets ;;
            6)  optimize_storage ;;
            7)  clean_ios_simulator ;;
            8)  clean_ios_ipsw ;;
            9)  clean_android_studio ;;
            10) clean_system_nodejs ;;
            11) clean_flutter_dart ;;
            12) clean_expo_react_native ;;
            13) clean_system_devtools ;;
            14) clean_docker ;;
            15) clean_crossover ;;
            16) cat "$LOG_FILE" | less ;;
            17) restart_macos ;;
            0)
                print_success "Goodbye!"
                log_action "Script finished"
                exit 0
                ;;
            *)
                print_error "Invalid option!"
                ;;
        esac

        echo ""
        read -p "Press ENTER to continue..."
    done
}

main
