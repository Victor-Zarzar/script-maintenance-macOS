#!/bin/bash

# ============================================
# Android Studio & Gradle Cleaning Functions
# ============================================

clean_android_studio() {
    print_section "Cleaning Android Studio & Emulator"

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
