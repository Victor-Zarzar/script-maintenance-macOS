#!/bin/bash

# ============================================
# IDE Cache Cleaning
# ============================================

cleanup_ide_caches() {
    print_section "IDE Cache Cleaning"

    local cleaned=0

    local jetbrains_path="$HOME/Library/Caches/JetBrains"
    if [ -d "$jetbrains_path" ]; then
        local size
        size=$(get_folder_size "$jetbrains_path")
        rm -rf "$jetbrains_path"/* 2>/dev/null
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        cleaned=$((cleaned + 1))
        print_success "Cleaned JetBrains cache ($(format_bytes $((size * 1024))))"
    else
        print_warning "JetBrains cache not found. Skipping."
    fi

    local vscode_base="$HOME/Library/Application Support/Code"
    if [ -d "$vscode_base" ]; then
        local size=0
        for dir in "Cache" "CachedData" "User/workspaceStorage"; do
            local p="$vscode_base/$dir"
            [ -d "$p" ] && size=$((size + $(get_folder_size "$p"))) && rm -rf "$p"/* 2>/dev/null
        done
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        cleaned=$((cleaned + 1))
        print_success "Cleaned VSCode cache ($(format_bytes $((size * 1024))))"
    else
        print_warning "VSCode cache not found. Skipping."
    fi

    local zed_base="$HOME/Library/Application Support/Zed"
    if [ -d "$zed_base" ]; then
        local size=0
        for dir in "browser_cache" "hang_traces" "logs"; do
            local p="$zed_base/$dir"
            [ -d "$p" ] && size=$((size + $(get_folder_size "$p"))) && rm -rf "$p"/* 2>/dev/null
        done
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        cleaned=$((cleaned + 1))
        print_success "Cleaned Zed cache ($(format_bytes $((size * 1024))))"
    else
        print_warning "Zed cache not found. Skipping."
    fi

    log_action "IDE caches cleaned ($cleaned IDEs)"
}
