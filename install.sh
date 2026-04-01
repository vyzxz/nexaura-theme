#!/bin/bash
set -e

# -------------------------------
# CONFIG
# -------------------------------
GITHUB_ZIP_URL="https://raw.githubusercontent.com/vyzxz/nexaura-theme/main/nexauratheme.zip"
PTERO_DIR="/var/www/pterodactyl"
TEMP_DIR="/tmp/nexaura_theme"
BACKUP_DIR="/var/www/pterodactyl_backup_$(date +%F_%T)"
LOG_FILE="/tmp/nexaura_install.log"

# -------------------------------
# FUNCTIONS
# -------------------------------
log() {
    echo -e "\e[1;32m[INFO]\e[0m $1" | tee -a $LOG_FILE
}

error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1" | tee -a $LOG_FILE
    exit 1
}

check_command() {
    command -v $1 >/dev/null 2>&1 || error "$1 is not installed."
}

# -------------------------------
# PRE-CHECKS
# -------------------------------
log "Checking dependencies..."
check_command curl
check_command unzip
check_command yarn
check_command php
check_command rsync

[ -d "$PTERO_DIR" ] || error "Pterodactyl not found"

cd $PTERO_DIR

# -------------------------------
# MAINTENANCE MODE
# -------------------------------
log "Enabling maintenance mode..."
php artisan down || true

# -------------------------------
# BACKUP
# -------------------------------
log "Backing up resources..."
mkdir -p $BACKUP_DIR
rsync -a resources/ $BACKUP_DIR/resources/

# -------------------------------
# DOWNLOAD (FIXED)
# -------------------------------
log "Downloading theme..."
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

curl -L --fail "$GITHUB_ZIP_URL" -o $TEMP_DIR/theme.zip || error "Download failed"

# Validate zip (IMPORTANT)
unzip -t $TEMP_DIR/theme.zip >/dev/null 2>&1 || error "Invalid zip file (wrong URL)"

# Extract
unzip -o $TEMP_DIR/theme.zip -d $TEMP_DIR || error "Unzip failed"

# -------------------------------
# FIND resources
# -------------------------------
log "Locating resources folder..."

THEME_RESOURCES=$(find $TEMP_DIR -type d -name "resources" | head -n 1)

[ -d "$THEME_RESOURCES" ] || error "resources folder not found in zip"

# -------------------------------
# INSTALL
# -------------------------------
log "Applying theme (full replace)..."

rsync -a --delete "$THEME_RESOURCES/" "$PTERO_DIR/resources/"

# -------------------------------
# BUILD
# -------------------------------
log "Preparing build..."

mkdir -p public/assets
rm -rf node_modules
rm -f yarn.lock
rm -rf public/assets/*

log "Installing dependencies..."
yarn install --silent || error "Yarn install failed"

log "Building production..."
yarn build:production || error "Build failed"

# -------------------------------
# CACHE
# -------------------------------
log "Clearing cache..."
php artisan optimize:clear

# -------------------------------
# FINALIZE
# -------------------------------
log "Disabling maintenance mode..."
php artisan up

log "✅ Nexaura Theme Installed Successfully"
echo "Backup: $BACKUP_DIR"
echo "Logs: $LOG_FILE"
