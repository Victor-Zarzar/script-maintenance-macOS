#!/bin/bash

# ============================================
# Node.js Ecosystem Cleaning Functions
# ============================================

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

clean_bun() {
    print_section "Cleaning Bun Cache"

    if command -v bun &> /dev/null; then
        local bun_version=$(bun --version 2>/dev/null)
        print_info "Bun version: $bun_version"

        local bun_cache_dir="$HOME/.bun/install/cache"
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
