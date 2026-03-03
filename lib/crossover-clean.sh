#!/bin/bash

# ============================================
# CrossOver Cache Cleaner
# ============================================

clean_crossover() {
    print_section "Cleaning CrossOver Cache"

    local cleaned=0

    local crossover_dirs=(
        "$HOME/Library/Application Support/CrossOver/Caches"
        "$HOME/Library/Caches/com.codeweavers.CrossOver"
        "$HOME/Library/Logs/CrossOver"
    )

    for dir in "${crossover_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local size=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
            print_info "Cleaning: $dir ($(format_bytes $((size * 1024))))"
            rm -rf "$dir"/* 2>/dev/null
            cleaned=$((cleaned + size))
        fi
    done

    local bottles_dir="$HOME/Library/Application Support/CrossOver/Bottles"
    if [[ -d "$bottles_dir" ]]; then
        print_info "Cleaning temp files inside CrossOver Bottles..."
        while IFS= read -r -d '' tmp_dir; do
            local size=$(du -sk "$tmp_dir" 2>/dev/null | awk '{print $1}')
            rm -rf "$tmp_dir"/* 2>/dev/null
            cleaned=$((cleaned + size))
        done < <(find "$bottles_dir" -type d \( -name "Temp" -o -name "temp" -o -name "tmp" \) -print0 2>/dev/null)

        while IFS= read -r -d '' wu_dir; do
            local size=$(du -sk "$wu_dir" 2>/dev/null | awk '{print $1}')
            print_info "Removing Windows Update cache: $wu_dir ($(format_bytes $((size * 1024))))"
            rm -rf "$wu_dir" 2>/dev/null
            cleaned=$((cleaned + size))
        done < <(find "$bottles_dir" -type d -name "SoftwareDistribution" -print0 2>/dev/null)
    fi

    TOTAL_CLEANED=$((TOTAL_CLEANED + cleaned))
    print_success "CrossOver: freed $(format_bytes $((cleaned * 1024)))"
    log_action "CrossOver cache cleaned - $(format_bytes $((cleaned * 1024)))"
}
