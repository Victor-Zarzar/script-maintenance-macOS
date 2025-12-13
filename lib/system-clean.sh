#!/bin/bash

# ============================================
# System Cleaning Functions
# ============================================

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
