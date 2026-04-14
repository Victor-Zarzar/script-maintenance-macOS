#!/bin/bash

# ============================================
# Browser Cleaning Caches
# ============================================

cleanup_browser_caches() {
    print_section "Browser Cleaning Caches"

    local cleaned=0

    local safari_path="$HOME/Library/Caches/com.apple.Safari"
    if [ -d "$safari_path" ]; then
        local size
        size=$(get_folder_size "$safari_path")
        rm -rf "$safari_path"/* 2>/dev/null
        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        cleaned=$((cleaned + 1))
        print_success "Cleaned Safari cache ($(format_bytes $((size * 1024))))"
    else
        print_warning "Safari cache not found. Skipping."
    fi

    # ── Chrome ──────────────────────────────
    local chrome_base="$HOME/Library/Application Support/Google/Chrome"
    if [ -d "$chrome_base" ]; then
        local size=0
        local cache_dirs=(
            "GrShaderCache"
            "ShaderCache"
            "GraphiteDawnCache"
            "component_crx_cache"
            "extensions_crx_cache"
        )
        for dir in "${cache_dirs[@]}"; do
            local p="$chrome_base/$dir"
            [ -d "$p" ] && size=$((size + $(get_folder_size "$p"))) && rm -rf "$p"/* 2>/dev/null
        done

        for profile_dir in "$chrome_base"/Default "$chrome_base"/Profile\ */; do
            [ -d "$profile_dir" ] || continue
            local profile_caches=(
                "GPUCache"
                "DawnGraphiteCache"
                "DawnWebGPUCache"
                "Service Worker/CacheStorage"
                "Service Worker/ScriptCache"
                "Shared Dictionary/cache"
                "optimization_guide_hint_cache_store"
                "AutofillAiModelCache"
            )
            for dir in "${profile_caches[@]}"; do
                local p="$profile_dir/$dir"
                [ -d "$p" ] && size=$((size + $(get_folder_size "$p"))) && rm -rf "$p"/* 2>/dev/null
            done
        done

        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        cleaned=$((cleaned + 1))
        print_success "Cleaned Chrome cache ($(format_bytes $((size * 1024))))"
    else
        print_warning "Chrome cache not found. Skipping."
    fi

    local orion_base="$HOME/Library/Application Support/Orion/Defaults"
    if [ -d "$orion_base" ]; then
        local size=0
        local orion_caches=(
            "Touch Icon Cache"
            "Thumbnail Cache"
            "SVG Cache"
            "Favicon Cache"
        )
        for dir in "${orion_caches[@]}"; do
            local p="$orion_base/$dir"
            [ -d "$p" ] && size=$((size + $(get_folder_size "$p"))) && rm -rf "$p"/* 2>/dev/null
        done

        TOTAL_CLEANED=$((TOTAL_CLEANED + size))
        cleaned=$((cleaned + 1))
        print_success "Cleaned Orion cache ($(format_bytes $((size * 1024))))"
    else
        print_warning "Orion cache not found. Skipping."
    fi

    log_action "Browser caches cleaned ($cleaned browsers)"
}
