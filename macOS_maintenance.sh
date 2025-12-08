#!/bin/bash

# ============================================
# Advanced macOS Maintenance Script
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

TOTAL_CLEANED=0
LOG_FILE="$HOME/macos_maintenance_$(date +%Y%m%d_%H%M%S).log"

# ============================================
# Helper Functions
# ============================================

print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   Advanced macOS Maintenance          ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${PURPLE}$1${NC}"
    echo "────────────────────────────────────────"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_folder_size() {
    local path="$1"
    if [ -d "$path" ]; then
        du -sk "$path" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

format_bytes() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    else
        echo "${bytes} B"
    fi
}

show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %d%%${NC}" $percentage
}

get_disk_usage() {
    df -h / | tail -1 | awk '{print $4}'
}

# ============================================
# Cleaning Functions
# ============================================

update_system() {
    print_section "Updating System and Homebrew"
    
    print_info "Checking for macOS updates..."
    softwareupdate -l 2>/dev/null | head -5
    
    if command -v brew &> /dev/null; then
        print_info "Updating Homebrew..."
        brew update &>/dev/null && print_success "Homebrew updated"
        brew upgrade &>/dev/null && print_success "Formulas upgraded"
        brew cleanup &>/dev/null && print_success "Homebrew cache cleaned"
        brew autoremove &>/dev/null
        brew doctor &>/dev/null
    else
        print_warning "Homebrew not found"
    fi
    
    log_action "System and Homebrew updated"
}

clean_software_update_cache() {
    print_section "Cleaning Update Cache"
    
    local paths=(
        "/Library/Updates"
        "$HOME/Library/Caches/com.apple.SoftwareUpdate"
        "/Library/Caches/com.apple.SoftwareUpdate"
    )
    
    for path in "${paths[@]}"; do
        if [ -d "$path" ]; then
            if [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
                print_info "$(basename "$path"): already clean"
                continue
            fi
            
            local size=$(get_folder_size "$path")
            
            if [[ "$path" == /Library/* ]]; then
                sudo rm -rf "$path"/* 2>/dev/null && \
                    print_success "$(basename "$path"): $(format_bytes $((size * 1024)))" || \
                    print_warning "$(basename "$path"): no permission or in use"
            else
                rm -rf "$path"/* 2>/dev/null && \
                    print_success "$(basename "$path"): $(format_bytes $((size * 1024)))"
            fi
            
            TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        else
            print_info "$(basename "$path"): not found"
        fi
    done
    
    log_action "Update cache cleaned"
}

clean_xcode_cache() {
    print_section "Cleaning Xcode Cache"
    
    local paths=(
        "$HOME/Library/Developer/Xcode/DerivedData"
        "$HOME/Library/Caches/com.apple.dt.Xcode"
        "$HOME/Library/Developer/Xcode/Archives"
        "$HOME/Library/Developer/CoreSimulator/Caches"
        "$HOME/Library/Caches/com.apple.dt.XCPGDeviceSupport"
    )
    
    for path in "${paths[@]}"; do
        if [ -d "$path" ]; then
            local size=$(get_folder_size "$path")
            rm -rf "$path" 2>/dev/null && \
                print_success "$(basename "$path"): $(format_bytes $((size * 1024)))"
            TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        fi
    done
    
    log_action "Xcode cache cleaned"
}

clean_ios_simulator() {
    print_section "Cleaning iOS Simulator"
    
    if command -v xcrun &> /dev/null; then
        print_info "Removing unavailable simulators..."
        xcrun simctl delete unavailable &>/dev/null && print_success "Simulators cleaned"
        
        print_warning "Erasing all simulator data..."
        xcrun simctl erase all &>/dev/null && print_success "Data erased"
    fi
    
    local sim_path="$HOME/Library/Developer/CoreSimulator/Devices"
    if [ -d "$sim_path" ]; then
        local size=$(get_folder_size "$sim_path")
        rm -rf "$sim_path" 2>/dev/null
        print_success "Cache removed: $(format_bytes $((size * 1024)))"
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
    fi
    
    log_action "iOS Simulator cleaned"
}

clean_ios_ipsw() {
    print_section "Cleaning iOS IPSW Files"
    
    local ipsw_paths=(
        "$HOME/Library/iTunes/iPhone Software Updates"
        "$HOME/Library/iTunes/iPad Software Updates"
        "$HOME/Library/iTunes/iPod Software Updates"
        "$HOME/Library/iTunes/Apple TV Software Updates"
        "$HOME/Library/iTunes/Apple Watch Software Updates"
    )
    
    local total_size=0
    local files_found=0
    
    for path in "${ipsw_paths[@]}"; do
        if [ -d "$path" ]; then
            local size=$(get_folder_size "$path")
            if [ "$size" -gt 0 ]; then
                local count=$(find "$path" -name "*.ipsw" 2>/dev/null | wc -l)
                if [ "$count" -gt 0 ]; then
                    print_info "Found $count IPSW file(s) in $(basename "$(dirname "$path")")"
                    rm -rf "$path"/*.ipsw 2>/dev/null && \
                        print_success "Removed: $(format_bytes $((size * 1024)))"
                    total_size=$((total_size + size))
                    files_found=$((files_found + count))
                fi
            fi
        fi
    done
    
    if [ "$files_found" -eq 0 ]; then
        print_info "No IPSW files found"
    else
        print_success "Total: $files_found file(s) - $(format_bytes $((total_size * 1024)))"
        TOTAL_CLEANED=$((TOTAL_CLEANED + total_size))
    fi
    
    log_action "iOS IPSW files cleaned"
}

clean_android_studio() {
    print_section "Cleaning Android Studio & Emulator"
    
    local android_paths=(
        "$HOME/.android/avd/*.avd/cache"
        "$HOME/.android/cache"
        "$HOME/.android/build-cache"
        "$HOME/Library/Caches/AndroidStudio*"
        "$HOME/Library/Application Support/Google/AndroidStudio*/caches"
        "$HOME/Library/Logs/Google/AndroidStudio*"
    )
    
    local total_size=0
    local items_cleaned=0
    
    if [ -d "$HOME/.android/avd" ]; then
        for avd_dir in "$HOME/.android/avd"/*.avd; do
            if [ -d "$avd_dir/cache" ]; then
                local size=$(get_folder_size "$avd_dir/cache")
                if [ "$size" -gt 0 ]; then
                    rm -rf "$avd_dir/cache"/* 2>/dev/null && \
                        print_success "AVD cache ($(basename "$avd_dir")): $(format_bytes $((size * 1024)))"
                    total_size=$((total_size + size))
                    items_cleaned=$((items_cleaned + 1))
                fi
            fi
        done
    fi
    
    local cache_dirs=(
        "$HOME/.android/cache"
        "$HOME/.android/build-cache"
    )
    
    for path in "${cache_dirs[@]}"; do
        if [ -d "$path" ]; then
            local size=$(get_folder_size "$path")
            if [ "$size" -gt 0 ]; then
                rm -rf "$path"/* 2>/dev/null && \
                    print_success "$(basename "$path"): $(format_bytes $((size * 1024)))"
                total_size=$((total_size + size))
                items_cleaned=$((items_cleaned + 1))
            fi
        fi
    done
    
    for pattern in "$HOME/Library/Caches/AndroidStudio"* "$HOME/Library/Application Support/Google/AndroidStudio"*/caches; do
        for path in $pattern; do
            if [ -d "$path" ]; then
                local size=$(get_folder_size "$path")
                if [ "$size" -gt 0 ]; then
                    rm -rf "$path"/* 2>/dev/null && \
                        print_success "Android Studio cache: $(format_bytes $((size * 1024)))"
                    total_size=$((total_size + size))
                    items_cleaned=$((items_cleaned + 1))
                fi
            fi
        done
    done
    
    for log_path in "$HOME/Library/Logs/Google/AndroidStudio"*; do
        if [ -d "$log_path" ]; then
            local size=$(get_folder_size "$log_path")
            if [ "$size" -gt 0 ]; then
                rm -rf "$log_path"/* 2>/dev/null && \
                    print_success "Android Studio logs: $(format_bytes $((size * 1024)))"
                total_size=$((total_size + size))
                items_cleaned=$((items_cleaned + 1))
            fi
        fi
    done
    
    if [ -d "$HOME/.gradle/caches" ]; then
        local gradle_size=$(get_folder_size "$HOME/.gradle/caches")
        if [ "$gradle_size" -gt 0 ]; then
            print_info "Gradle cache found: $(format_bytes $((gradle_size * 1024)))"
            print_warning "Removing entire Gradle cache (will be rebuilt on next build)..."
            
            rm -rf "$HOME/.gradle/caches"/* 2>/dev/null && \
                print_success "Gradle cache removed: $(format_bytes $((gradle_size * 1024)))"
            
            total_size=$((total_size + gradle_size))
            items_cleaned=$((items_cleaned + 1))
        fi
    fi
    
    if [ -d "$HOME/.gradle/wrapper" ]; then
        local wrapper_size=$(get_folder_size "$HOME/.gradle/wrapper")
        if [ "$wrapper_size" -gt 102400 ]; then
            print_info "Gradle wrapper found: $(format_bytes $((wrapper_size * 1024)))"
            print_warning "Keeping only latest wrapper version..."
            
            cd "$HOME/.gradle/wrapper/dists" 2>/dev/null
            if [ $? -eq 0 ]; then
                ls -t | tail -n +2 | xargs rm -rf 2>/dev/null
                local new_wrapper_size=$(get_folder_size "$HOME/.gradle/wrapper")
                local cleaned_wrapper=$((wrapper_size - new_wrapper_size))
                if [ "$cleaned_wrapper" -gt 0 ]; then
                    print_success "Old Gradle wrappers removed: $(format_bytes $((cleaned_wrapper * 1024)))"
                    total_size=$((total_size + cleaned_wrapper))
                fi
            fi
        fi
    fi
    
    if [ -d "$HOME/.gradle/daemon" ]; then
        find "$HOME/.gradle/daemon" -name "*.log" -mtime +7 -delete 2>/dev/null && \
            print_success "Old Gradle daemon logs removed"
    fi
    
    if [ -d "$HOME/Projects" ]; then
        print_info "Scanning for project .gradle folders..."
        local project_gradle_size=0
        while IFS= read -r gradle_dir; do
            local size=$(get_folder_size "$gradle_dir")
            project_gradle_size=$((project_gradle_size + size))
        done < <(find "$HOME/Projects" -type d -name ".gradle" 2>/dev/null)
        
        if [ "$project_gradle_size" -gt 0 ]; then
            print_warning "Found $(format_bytes $((project_gradle_size * 1024))) in project .gradle folders"
            echo -n "Remove project build caches? (y/N): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                find "$HOME/Projects" -type d -name ".gradle" -exec rm -rf {} + 2>/dev/null
                print_success "Project .gradle folders removed: $(format_bytes $((project_gradle_size * 1024)))"
                total_size=$((total_size + project_gradle_size))
                items_cleaned=$((items_cleaned + 1))
            fi
        fi
    fi
    
    if [ "$items_cleaned" -eq 0 ]; then
        print_info "No Android Studio/Emulator/Gradle cache found"
    else
        print_success "Total Android + Gradle cleaned: $(format_bytes $((total_size * 1024)))"
        TOTAL_CLEANED=$((TOTAL_CLEANED + total_size))
    fi
    
    log_action "Android Studio, Emulator & Gradle cleaned (full cache removal)"
}

clean_nvm_npm() {
    print_section "Cleaning NPM/NVM Cache"
    
    if [ -d "$HOME/.nvm" ]; then
        local npm_cache="$HOME/.npm"
        if [ -d "$npm_cache" ]; then
            local size=$(get_folder_size "$npm_cache")
            rm -rf "$npm_cache" 2>/dev/null && \
                print_success "npm cache: $(format_bytes $((size * 1024)))"
            TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        fi
        
        if command -v npm &> /dev/null; then
            npm cache clean --force &>/dev/null && print_success "npm cache cleaned"
            npm cache verify &>/dev/null
        fi
    else
        print_info "NVM not found"
    fi
    
    log_action "NPM/NVM cleaned"
}

clean_bun() {
    print_section "Cleaning Bun Cache"
    
    if command -v bun &> /dev/null; then
        local bun_version=$(bun --version 2>/dev/null)
        print_info "Bun version: $bun_version"
        
        local bun_cache_dir="$HOME/.bun/install/cache"
        local bun_global_dir="$HOME/.bun/install/global"
        
        local total_size=0
        
        if [ -d "$bun_cache_dir" ]; then
            local cache_size=$(get_folder_size "$bun_cache_dir")
            if [ "$cache_size" -gt 0 ]; then
                print_info "Bun cache found: $(format_bytes $((cache_size * 1024)))"
                rm -rf "$bun_cache_dir"/* 2>/dev/null && \
                    print_success "Bun cache cleared: $(format_bytes $((cache_size * 1024)))"
                total_size=$((total_size + cache_size))
            fi
        fi
        
        if [ -d "$HOME/.bun/install" ]; then
            find "$HOME/.bun/install" -name ".tmp-*" -type d -exec rm -rf {} + 2>/dev/null && \
                print_success "Bun temporary files removed"
        fi
        
        local bun_logs="$HOME/.bun/logs"
        if [ -d "$bun_logs" ]; then
            local logs_size=$(get_folder_size "$bun_logs")
            if [ "$logs_size" -gt 0 ]; then
                rm -rf "$bun_logs"/* 2>/dev/null && \
                    print_success "Bun logs cleared: $(format_bytes $((logs_size * 1024)))"
                total_size=$((total_size + logs_size))
            fi
        fi
        
        if [ "$total_size" -eq 0 ]; then
            print_info "Bun cache is already clean"
        else
            print_success "Total Bun cleaned: $(format_bytes $((total_size * 1024)))"
            TOTAL_CLEANED=$((TOTAL_CLEANED + total_size))
        fi
    else
        print_info "Bun not found"
    fi
    
    log_action "Bun cache cleaned"
}

clean_flutter_dart() {
    print_section "Cleaning Flutter/Dart/FVM Cache"
    
    if command -v flutter &> /dev/null; then
        local paths=(
            "$HOME/.flutter-devtools"
            "$HOME/.flutter/bin/cache"
        )
        
        for path in "${paths[@]}"; do
            if [ -d "$path" ]; then
                local size=$(get_folder_size "$path")
                rm -rf "$path" 2>/dev/null
                TOTAL_CLEANED=$((TOTAL_CLEANED + size))
            fi
        done
        
        print_info "Cleaning pub cache..."
        echo 'y' | flutter pub cache clean &>/dev/null
        flutter pub cache repair &>/dev/null && print_success "Flutter pub cache cleaned"
    else
        print_info "Flutter not found"
    fi
    
    if command -v dart &> /dev/null; then
        dart pub cache repair &>/dev/null && print_success "Dart pub cache repaired"
    fi
    
    if command -v fvm &> /dev/null; then
        print_info "FVM found - use 'fvm remove <version>' for specific versions"
    fi
    
    log_action "Flutter/Dart/FVM cleaned"
}

clean_system_caches() {
    print_section "Cleaning System Caches"
    
    local cache_dir="$HOME/Library/Caches"
    if [ -d "$cache_dir" ]; then
        local size=$(get_folder_size "$cache_dir")
        local count=0
        local total=$(find "$cache_dir" -mindepth 1 -maxdepth 1 | wc -l)
        
        for item in "$cache_dir"/*; do
            rm -rf "$item" 2>/dev/null
            ((count++))
            show_progress $count $total
        done
        echo ""
        
        print_success "Caches cleaned: $(format_bytes $((size * 1024)))"
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
    fi
    
    local other_paths=(
        "$HOME/Library/Logs"
        "$HOME/Library/Application Support/CrashReporter"
    )
    
    for path in "${other_paths[@]}"; do
        if [ -d "$path" ]; then
            local size=$(get_folder_size "$path")
            rm -rf "$path"/* 2>/dev/null
            TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        fi
    done
    
    log_action "System caches cleaned"
}

clean_downloads_trash() {
    print_section "Cleaning Downloads and Trash"
    
    print_info "Emptying trash..."
    rm -rf "$HOME/.Trash"/* 2>/dev/null && print_success "Trash emptied"
    
    print_info "Removing old downloads (+30 days)..."
    find "$HOME/Downloads" -type f -mtime +30 -delete 2>/dev/null && \
        print_success "Old downloads removed"
    
    log_action "Downloads and trash cleaned"
}

clean_logs() {
    print_section "Cleaning Old Logs"
    
    find "$HOME/Library/Logs" -name "*.log" -mtime +7 -delete 2>/dev/null && \
        print_success "Old logs removed"
    
    log_action "Old logs removed"
}

optimize_storage() {
    print_section "Optimizing Storage"
    
    print_info "Removing local Time Machine snapshots..."
    sudo tmutil deletelocalsnapshots / 2>/dev/null && \
        print_success "Snapshots removed" || \
        print_info "No snapshots found"
    
    local photos_cache="$HOME/Pictures/Photos Library.photoslibrary/resources/caches"
    if [ -d "$photos_cache" ]; then
        local size=$(get_folder_size "$photos_cache")
        rm -rf "$photos_cache" 2>/dev/null && \
            print_success "Photos cache: $(format_bytes $((size * 1024)))"
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
    fi
    
    log_action "Storage optimized"
}

clean_docker() {
    print_section "Cleaning Docker"
    
    if command -v docker &> /dev/null; then
        print_info "Stopping containers..."
        docker stop $(docker ps -q) 2>/dev/null
        
        print_info "Cleaning Docker system..."
        docker system prune -af --volumes &>/dev/null && \
            print_success "Docker cleaned"
        
        docker builder prune -af &>/dev/null && \
            print_success "Build cache cleaned"
    else
        print_info "Docker not found"
    fi
    
    log_action "Docker cleaned"
}

# ============================================
# Interactive Menu
# ============================================

show_menu() {
    clear
    print_header
    echo -e "${YELLOW}Current free space: $(get_disk_usage)${NC}"
    echo ""
    echo "1)  Run complete maintenance"
    echo "2)  Update system and Homebrew"
    echo "3)  Clean update cache"
    echo "4)  Clean Xcode cache"
    echo "5)  Clean iOS simulator" 
    echo "6)  Clean iOS firmwares (IPSW)"
    echo "7)  Clean Android Studio & Emulator"
    echo "8)  Clean NPM/NVM"
    echo "9)  Clean Bun"
    echo "10) Clean Flutter/Dart/FVM"
    echo "11) Clean system caches"
    echo "12) Clean downloads and trash"
    echo "13) Clean old logs"
    echo "14) Optimize storage"
    echo "15) Clean Docker"
    echo "16) View action log"
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
    clean_xcode_cache
    clean_ios_simulator
    clean_ios_ipsw
    clean_android_studio
    clean_nvm_npm
    clean_bun
    clean_flutter_dart
    clean_system_caches
    clean_downloads_trash
    clean_logs
    optimize_storage
    clean_docker
    
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
            1) run_full_maintenance ;;
            2) update_system ;;
            3) clean_software_update_cache ;;
            4) clean_xcode_cache ;;
            5) clean_ios_simulator ;;
            6) clean_ios_ipsw ;;
            7) clean_android_studio ;;
            8) clean_nvm_npm ;;
            9) clean_bun ;;
            10) clean_flutter_dart ;;
            11) clean_system_caches ;;
            12) clean_downloads_trash ;;
            13) clean_logs ;;
            14) optimize_storage ;;
            15) clean_docker ;;
            16) cat "$LOG_FILE" | less ;;
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