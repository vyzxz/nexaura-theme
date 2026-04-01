#!/bin/bash

set -e  # Exit immediately if a command fails

# -------------------------------
# CONFIG
# -------------------------------
GITHUB_ZIP_URL="https://raw.githubusercontent.com/vyzxz/nexaura-theme/main/nexauratheme.zip"
PTERO_DIR="/var/www/pterodactyl"
ZIP_FILE="nexauratheme.zip"
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
    command -v $1 >/dev/null 2>&1 || error "$1 is not installed. Install it first."
}

# -------------------------------
# PRE-CHECKS
# -------------------------------
log "Checking dependencies..."
check_command curl
check_command unzip
check_command yarn
check_command php

[ -d "$PTERO_DIR" ] || error "Pterodactyl directory not found!"

cd $PTERO_DIR

# -------------------------------
# MAINTENANCE MODE
# -------------------------------
log "Enabling maintenance mode..."
php artisan down || log "Already in maintenance mode."

# -------------------------------
# BACKUP
# -------------------------------
log "Creating backup at $BACKUP_DIR..."
cp -r $PTERO_DIR $BACKUP_DIR || error "Backup failed!"

# -------------------------------
# DOWNLOAD
# -------------------------------
log "Downloading theme..."
curl -fL "$GITHUB_ZIP_URL" -o $ZIP_FILE || error "Download failed!"

# Validate zip
if ! unzip -t $ZIP_FILE >/dev/null 2>&1; then
    error "Zip file is corrupted!"
fi

# -------------------------------
# INSTALL
# -------------------------------
log "Extracting theme..."
unzip -o $ZIP_FILE || error "Extraction failed!"
rm -f $ZIP_FILE

# -------------------------------
# BUILD
# -------------------------------
log "Installing dependencies..."
yarn install --silent || error "Yarn install failed!"

log "Building production assets..."
yarn build:production || error "Build failed!"

# -------------------------------
# CLEANUP & CACHE
# -------------------------------
log "Clearing cache..."
php artisan view:clear
php artisan config:clear
php artisan cache:clear

# -------------------------------
# FINALIZE
# -------------------------------
log "Disabling maintenance mode..."
php artisan up

log "✅ Nexaura Theme Installed Successfully!"
echo "Backup saved at: $BACKUP_DIR"
echo "Logs saved at: $LOG_FILE"
