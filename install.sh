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

[ -d "$PTERO_DIR" ] || error "Pterodactyl not found"

cd $PTERO_DIR

# -------------------------------
# MAINTENANCE MODE
# -------------------------------
log "Enabling maintenance mode..."
php artisan down || true

# -------------------------------
# BACKUP (ONLY resources)
# -------------------------------
log "Backing up resources..."
mkdir -p $BACKUP_DIR
rsync -a resources/ $BACKUP_DIR/resources/

# -------------------------------
# DOWNLOAD
# -------------------------------
log "Downloading theme..."
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

curl -L "$GITHUB_ZIP_URL" -o $TEMP_DIR/theme.zip || error "Download failed"
unzip $TEMP_DIR/theme.zip -d $TEMP_DIR || error "Unzip failed"

THEME_DIR=$(find $TEMP_DIR -maxdepth 1 -type d -name "nexaura-theme-*")
[ -d "$THEME_DIR" ] || error "Theme folder not found"

# -------------------------------
# INSTALL (ONLY resources)
# -------------------------------
log "Applying theme (resources only)..."

if [ -d "$THEME_DIR/resources" ]; then
    rsync -a --delete $THEME_DIR/resources/ $PTERO_DIR/resources/
else
    error "Theme missing resources folder"
fi

# -------------------------------
# FIX BUILD ENV
# -------------------------------
log "Preparing build environment..."

# Ensure assets folder exists (NOT overwriting public)
mkdir -p public/assets

# Clean old build
rm -rf node_modules
rm -f yarn.lock
rm -rf public/assets/*

# -------------------------------
# BUILD
# -------------------------------
log "Installing dependencies..."
yarn install --silent || error "Yarn install failed"

log "Building production..."
yarn build:production || error "Build failed"

# -------------------------------
# CACHE CLEAN
# -------------------------------
log "Clearing cache..."
php artisan optimize:clear

# -------------------------------
# FINALIZE
# -------------------------------
log "Disabling maintenance mode..."
php artisan up

log "✅ Nexaura Theme Installed (Resources Only)"
echo "Backup: $BACKUP_DIR"
echo "Logs: $LOG_FILE"
