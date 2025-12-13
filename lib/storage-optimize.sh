#!/bin/bash

# ============================================
# Storage Optimization Functions
# ============================================

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
