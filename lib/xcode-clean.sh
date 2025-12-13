#!/bin/bash

# ============================================
# Xcode Cleaning Functions
# ============================================

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
