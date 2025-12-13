#!/bin/bash

# ============================================
# System Update Functions
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
