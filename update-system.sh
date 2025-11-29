#!/bin/bash

################################################################################
# System Update Script with Docker Support
# Description: Updates system packages, manages Docker images, and handles logs
# Author: Your Name
# License: MIT
################################################################################

set -o pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${SCRIPT_DIR}/update-system.log"
LOG_MAX_SIZE=$((20 * 1024 * 1024))  # 20MB in bytes
LOG_RETENTION_DAYS=10
DOCKER_IGNORE_FILE="${SCRIPT_DIR}/docker-ignore.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

################################################################################
# Initialization
################################################################################

initialize() {
    # Create logs directory if it doesn't exist
    if [[ ! -d "${LOG_DIR}" ]]; then
        mkdir -p "${LOG_DIR}"
        if [[ $? -eq 0 ]]; then
            log_message "Created logs directory: ${LOG_DIR}"
        else
            echo "ERROR: Failed to create logs directory: ${LOG_DIR}" >&2
            exit 1
        fi
    fi
}

################################################################################
# Logging Functions
################################################################################

log_message() {
    echo "[${TIMESTAMP}] $1" | tee -a "${LOG_FILE}"
}

log_error() {
    echo "[${TIMESTAMP}] ERROR: $1" | tee -a "${LOG_FILE}" >&2
}

log_success() {
    echo "[${TIMESTAMP}] SUCCESS: $1" | tee -a "${LOG_FILE}"
}

################################################################################
# Log Rotation
################################################################################

rotate_logs() {
    if [[ -f "${LOG_FILE}" ]]; then
        local file_size=$(stat -f%z "${LOG_FILE}" 2>/dev/null || stat -c%s "${LOG_FILE}" 2>/dev/null)
        
        if [[ ${file_size} -ge ${LOG_MAX_SIZE} ]]; then
            log_message "Log file size (${file_size} bytes) exceeds ${LOG_MAX_SIZE} bytes. Rotating..."
            
            # Archive name with timestamp
            local archive_name="${LOG_DIR}/update-system.log.$(date +%Y%m%d_%H%M%S).gz"
            
            # Compress and move to logs directory
            gzip -c "${LOG_FILE}" > "${archive_name}"
            
            if [[ $? -eq 0 ]]; then
                > "${LOG_FILE}"  # Truncate the log file
                log_message "Log rotated to ${archive_name}"
            else
                log_error "Failed to rotate log file"
            fi
        fi
    fi
    
    # Move any old compressed logs from script directory to logs directory
    if ls "${SCRIPT_DIR}"/update-system.log.*.gz 1> /dev/null 2>&1; then
        log_message "Moving old compressed logs to logs directory..."
        mv "${SCRIPT_DIR}"/update-system.log.*.gz "${LOG_DIR}/" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            log_message "Old logs moved successfully"
        fi
    fi
    
    # Delete old compressed logs from logs directory
    local deleted_count=$(find "${LOG_DIR}" -name "update-system.log.*.gz" -type f -mtime +${LOG_RETENTION_DAYS} -delete -print | wc -l)
    if [[ ${deleted_count} -gt 0 ]]; then
        log_message "Cleaned up ${deleted_count} log file(s) older than ${LOG_RETENTION_DAYS} days"
    fi
}

################################################################################
# System Update Functions
################################################################################

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
}

update_package_lists() {
    log_message "Updating package lists..."
    if apt-get update 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Package lists updated successfully"
        return 0
    else
        log_error "Failed to update package lists"
        return 1
    fi
}

upgrade_packages() {
    log_message "Upgrading packages..."
    if DEBIAN_FRONTEND=noninteractive apt-get upgrade -y 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Packages upgraded successfully"
        return 0
    else
        log_error "Failed to upgrade packages"
        return 1
    fi
}

dist_upgrade() {
    log_message "Performing distribution upgrade..."
    if DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Distribution upgrade completed successfully"
        return 0
    else
        log_error "Failed to perform distribution upgrade"
        return 1
    fi
}

fix_broken_packages() {
    log_message "Fixing broken packages..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -f -y 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Broken packages fixed successfully"
        return 0
    else
        log_error "Failed to fix broken packages"
        return 1
    fi
}

remove_unnecessary_packages() {
    log_message "Removing unnecessary packages..."
    if DEBIAN_FRONTEND=noninteractive apt-get autoremove -y 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Unnecessary packages removed successfully"
        return 0
    else
        log_error "Failed to remove unnecessary packages"
        return 1
    fi
}

clean_apt_cache() {
    log_message "Cleaning APT cache..."
    if apt-get clean 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "APT cache cleaned successfully"
        return 0
    else
        log_error "Failed to clean APT cache"
        return 1
    fi
}

################################################################################
# Docker Functions
################################################################################

check_docker() {
    if command -v docker &> /dev/null; then
        log_message "Docker is installed"
        return 0
    else
        log_message "Docker is not installed, skipping Docker updates"
        return 1
    fi
}

load_docker_ignore_list() {
    local ignore_list=()
    
    if [[ -f "${DOCKER_IGNORE_FILE}" ]]; then
        log_message "Loading Docker ignore list from ${DOCKER_IGNORE_FILE}"
        while IFS= read -r line; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
            ignore_list+=("$line")
        done < "${DOCKER_IGNORE_FILE}"
    else
        log_message "No Docker ignore file found at ${DOCKER_IGNORE_FILE}"
    fi
    
    printf '%s\n' "${ignore_list[@]}"
}

should_ignore_image() {
    local image="$1"
    shift
    local ignore_patterns=("$@")
    
    for pattern in "${ignore_patterns[@]}"; do
        # Convert wildcard pattern to regex
        local regex_pattern="${pattern//\*/.*}"
        if [[ "$image" =~ ^${regex_pattern}$ ]]; then
            return 0  # Should ignore
        fi
    done
    
    return 1  # Should not ignore
}

update_docker_images() {
    log_message "Starting Docker image updates..."
    
    # Load ignore list
    mapfile -t ignore_list < <(load_docker_ignore_list)
    
    # Get all images
    local images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")
    
    local updated=0
    local skipped=0
    local failed=0
    
    while IFS= read -r image; do
        if should_ignore_image "$image" "${ignore_list[@]}"; then
            log_message "Skipping ignored image: $image"
            ((skipped++))
            continue
        fi
        
        log_message "Pulling latest version of $image..."
        if docker pull "$image" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "Successfully updated $image"
            ((updated++))
        else
            log_error "Failed to update $image"
            ((failed++))
        fi
    done <<< "$images"
    
    # Clean up dangling images
    log_message "Cleaning up dangling images..."
    docker image prune -f 2>&1 | tee -a "${LOG_FILE}"
    
    log_message "Docker update summary: $updated updated, $skipped skipped, $failed failed"
}

################################################################################
# Main Function
################################################################################

main() {
    # Initialize environment
    initialize
    
    # Check for root privileges
    check_root
    
    # Rotate logs if needed
    rotate_logs
    
    log_message "========================================="
    log_message "Starting system update process"
    log_message "========================================="
    
    # System updates
    update_package_lists
    upgrade_packages
    dist_upgrade
    fix_broken_packages
    remove_unnecessary_packages
    clean_apt_cache
    
    # Docker updates (if installed)
    if check_docker; then
        update_docker_images
    fi
    
    log_message "========================================="
    log_message "System update process completed"
    log_message "========================================="
    
    echo ""
    echo "Update completed! Check ${LOG_FILE} for details."
    echo "Archived logs are stored in: ${LOG_DIR}"
}

# Run main function
main "$@"
