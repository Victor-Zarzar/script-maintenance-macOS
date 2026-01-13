#!/bin/bash
# ============================================
# macOS Restart Function
# ============================================

restart_macos() {
    print_section "System Restart"
    echo -e "${YELLOW}This will restart your Mac immediately!${NC}"
    echo -e "${YELLOW}Make sure to save all your work before proceeding.${NC}"
    echo ""
    echo -n "Are you sure you want to restart now? (yes/no): "
    read -r confirm

    if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
        print_warning "Restarting in 5 seconds... (Press Ctrl+C to cancel)"
        sleep 1
        echo "4..."
        sleep 1
        echo "3..."
        sleep 1
        echo "2..."
        sleep 1
        echo "1..."
        sleep 1
        log_action "System restart initiated by user"
        sudo shutdown -r now
    else
        print_info "Restart cancelled"
    fi
}
