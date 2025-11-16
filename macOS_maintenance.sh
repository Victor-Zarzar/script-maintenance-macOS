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

clean_pnpm() {
    print_section "Cleaning PNPM Cache"
    
    if command -v pnpm &> /dev/null; then
        local paths=(
            "$HOME/.pnpm-store"
            "$HOME/Library/pnpm/store"
            "$HOME/.local/share/pnpm/store"
        )
        
        for path in "${paths[@]}"; do
            if [ -d "$path" ]; then
                local size=$(get_folder_size "$path")
                TOTAL_CLEANED=$((TOTAL_CLEANED + size))
            fi
        done
        
        pnpm store prune &>/dev/null && print_success "pnpm store cleaned"
    else
        print_info "PNPM not found"
    fi
    
    log_action "PNPM cleaned"
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
    echo "6)  clean iOS firmwares (IPSW)"
    echo "7)  Clean NPM/NVM"
    echo "8)  Clean PNPM"
    echo "9)  Clean Flutter/Dart/FVM"
    echo "10)  Clean system caches"
    echo "11) Clean downloads and trash"
    echo "12) Clean old logs"
    echo "13) Optimize storage"
    echo "14) Clean Docker"
    echo "15) View action log"
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
    clean_nvm_npm
    clean_pnpm
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
            7) clean_nvm_npm ;;
            8) clean_pnpm ;;
            9) clean_flutter_dart ;;
            10) clean_system_caches ;;
            11) clean_downloads_trash ;;
            12) clean_logs ;;
            13) optimize_storage ;;
            14) clean_docker ;;
            15) cat "$LOG_FILE" | less ;;
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