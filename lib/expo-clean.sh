#!/bin/bash

# ============================================
# Expo / React Native Cache Cleaner
# ============================================

clean_expo_react_native() {
    print_section "Cleaning Expo & React Native Cache"

    local cleaned=0

    local metro_cache="$TMPDIR/metro-*"
    for dir in $metro_cache; do
        if [[ -d "$dir" ]]; then
            local size=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
            print_info "Metro cache: $dir ($(format_bytes $((size * 1024))))"
            rm -rf "$dir"
            cleaned=$((cleaned + size))
        fi
    done

    for pattern in "$TMPDIR/haste-map-*" "$TMPDIR/react-*"; do
        for dir in $pattern; do
            if [[ -d "$dir" ]]; then
                local size=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
                print_info "RN temp: $dir ($(format_bytes $((size * 1024))))"
                rm -rf "$dir"
                cleaned=$((cleaned + size))
            fi
        done
    done

    if command -v watchman &>/dev/null; then
        print_info "Flushing Watchman watches..."
        watchman watch-del-all 2>/dev/null
        local wm_dir="$HOME/Library/Caches/watchman"
        if [[ -d "$wm_dir" ]]; then
            local size=$(du -sk "$wm_dir" 2>/dev/null | awk '{print $1}')
            rm -rf "$wm_dir"
            cleaned=$((cleaned + size))
        fi
        print_success "Watchman flushed"
    fi

    local expo_dirs=(
        "$HOME/.expo"
        "$HOME/Library/Caches/Expo"
        "$HOME/.expo-shared"
    )
    for dir in "${expo_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local size=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
            print_info "Expo cache: $dir ($(format_bytes $((size * 1024))))"
            rm -rf "$dir"
            cleaned=$((cleaned + size))
        fi
    done

    local eas_cache="$HOME/Library/Caches/eas-cli"
    if [[ -d "$eas_cache" ]]; then
        local size=$(du -sk "$eas_cache" 2>/dev/null | awk '{print $1}')
        print_info "EAS CLI cache: $(format_bytes $((size * 1024)))"
        rm -rf "$eas_cache"
        cleaned=$((cleaned + size))
    fi

    local gradle_cache="$HOME/.gradle/caches"
    if [[ -d "$gradle_cache" ]]; then
        local size=$(du -sk "$gradle_cache" 2>/dev/null | awk '{print $1}')
        print_info "Gradle cache: $(format_bytes $((size * 1024)))"
        rm -rf "$gradle_cache"
        cleaned=$((cleaned + size))
    fi

    local rn_android_builds
    rn_android_builds=$(find "$HOME" -maxdepth 5 \
        -path "*/android/app/build" -o \
        -path "*/android/.gradle" \
        2>/dev/null)
    if [[ -n "$rn_android_builds" ]]; then
        while IFS= read -r build_dir; do
            if [[ -d "$build_dir" ]]; then
                local size=$(du -sk "$build_dir" 2>/dev/null | awk '{print $1}')
                print_info "RN Android build: $build_dir ($(format_bytes $((size * 1024))))"
                rm -rf "$build_dir"
                cleaned=$((cleaned + size))
            fi
        done <<< "$rn_android_builds"
    fi

    TOTAL_CLEANED=$((TOTAL_CLEANED + cleaned))
    print_success "Expo/React Native: freed $(format_bytes $((cleaned * 1024)))"
    log_action "Expo/React Native cache cleaned - $(format_bytes $((cleaned * 1024)))"
}
