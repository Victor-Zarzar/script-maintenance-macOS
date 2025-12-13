#!/bin/bash

# ============================================
# iOS Cleaning Functions
# ============================================

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
