# 🚀 Nexaura Theme for Pterodactyl

A modern, clean, and performance-focused theme for the **Pterodactyl Panel** built by **VyzxStudios**.

---

## ✨ Features

* 🎨 Modern UI (Tailwind-based)
* ⚡ Fast & optimized build
* 🧩 Fully compatible with latest Pterodactyl
* 🔧 Easy installation (1 command)
* 🛡️ Safe installer with backup system

---

## 📦 Requirements

Make sure your system has:

* PHP (>= 8.x)
* Node.js & Yarn
* curl
* unzip
* Pterodactyl Panel installed

---

## ⚡ Quick Install (Recommended)

Run this command inside your server:

```bash
bash <(curl -s https://raw.githubusercontent.com/vyzxz/nexaura-theme/main/install.sh)
```

---

## 🛠️ Manual Installation

```bash
cd /var/www/pterodactyl
php artisan down

curl -L https://github.com/vyzxz/nexaura-theme/archive/refs/heads/main.zip -o theme.zip
unzip -o theme.zip
rm theme.zip

yarn install
yarn build:production

php artisan view:clear
php artisan config:clear
php artisan up
```

---

## 🔁 Updating Theme

Re-run the installer:

```bash
bash <(curl -s https://raw.githubusercontent.com/vyzxz/nexaura-theme/main/install.sh)
```

---

## 🧯 Backup & Safety

* Installer automatically creates a backup before applying changes
* Backup location:

```
/var/www/pterodactyl_backup_*
```

---

## 🐛 Troubleshooting

### Build Fails?

```bash
yarn install --check-files
```

### Permission Issues?

```bash
chown -R www-data:www-data /var/www/pterodactyl
```

### Clear Everything

```bash
php artisan optimize:clear
```

---

## 👨‍💻 Author

**VyzxStudios**
Made with ⚡ by Vansh

---

## ⭐ Support

If you like this project, consider giving it a ⭐ on GitHub.

---

## ⚠️ Disclaimer

This theme modifies core panel files. Always keep backups before installing.

---
