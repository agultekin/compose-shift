#!/usr/bin/env bash
# ==============================================================================
# Script Name: docker-switch.sh
# Description: Gracefully stops all active Docker Compose stacks on the system 
#              and starts the Docker Compose stack in the specified directory.
# Ideal for developers working with Git worktrees or multiple project branches.
# ==============================================================================

set -euo pipefail

# Print styled log messages
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

# 1. Determine target directory (argument or current directory)
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    log_error "Target directory '$TARGET_DIR' does not exist."
    exit 1
fi

TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

# 2. Retrieve config files of all currently running Docker Compose projects
log_info "Scanning for active Docker Compose projects..."
ACTIVE_COMPOSE_FILES=$(docker ps --format '{{.Label "com.docker.compose.project.config_files"}}' | sort -u | grep -v '^$' || true)

# 3. Stop running Docker Compose services
if [ -n "$ACTIVE_COMPOSE_FILES" ]; then
    log_info "Stopping active Docker Compose projects..."
    while IFS= read -r compose_file; do
        if [ -f "$compose_file" ]; then
            log_info "Stopping: $compose_file"
            docker compose -f "$compose_file" stop
        else
            log_info "Skipping stale reference: $compose_file"
        fi
    done <<< "$ACTIVE_COMPOSE_FILES"
    log_success "All active stacks have been stopped."
else
    log_info "No active Docker Compose stacks found."
fi

# 4. Start Docker Compose in the target directory
cd "$TARGET_DIR"

if [ -f "compose.yaml" ] || [ -f "compose.yml" ] || [ -f "docker-compose.yaml" ] || [ -f "docker-compose.yml" ]; then
    log_info "Starting Docker Compose stack in: $TARGET_DIR"
    docker compose up -d
    log_success "Target environment is up and running!"
else
    log_error "No valid Docker Compose file found in $TARGET_DIR"
    exit 1
fi
