#!/usr/bin/env bash
# Bootstrap installer for Digital PIN on a fresh Ubuntu 20.04/22.04 server
# Usage (on the server as root or via sudo):
#   REPO_URL="git@github.com:org/repo.git" DOMAIN="digitalpin.onlin" LETS_EMAIL="you@example.com" DB_PASS="StrongPassHere" sudo bash ./bootstrap_digitalpin_hetzner.sh

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Required env vars
: "${REPO_URL:?Must set REPO_URL}"
: "${DOMAIN:?Must set DOMAIN}"
: "${LETS_EMAIL:?Must set LETS_EMAIL}"
: "${DB_PASS:?Must set DB_PASS}"

BRANCH="deploy/docker-clean"
DEPLOY_USER="deploy"
WEB_ROOT="/var/www/digital-pin"
DOL_DATA_ROOT="/var/dolibarr_data"
DB_NAME="dolibarr"
DB_USER="dolibarr"
PHP_VERSION="8.1"

echo "==> Running bootstrap for Digital PIN"
echo "Domain: $DOMAIN"

# 1. Update system
apt update && apt upgrade -y

# 2. Create deploy user if missing
if ! id -u "$DEPLOY_USER" >/dev/null 2>&1; then
  echo "==> Creating deploy user"
  adduser --disabled-password --gecos "" "$DEPLOY_USER"
  usermod -aG sudo "$DEPLOY_USER"
fi

# 3. Install base packages
apt install -y software-properties-common curl gnupg2 apt-transport-https ca-certificates lsb-release
add-apt-repository ppa:ondrej/php -y || true
apt update
apt install -y nginx mariadb-server git unzip
apt install -y php${PHP_VERSION} php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-gd php${PHP_VERSION}-curl php${PHP_VERSION}-intl php${PHP_VERSION}-mbstring php${PHP_VERSION}-zip php${PHP_VERSION}-cli php${PHP_VERSION}-opcache php${PHP_VERSION}-soap
apt install -y certbot python3-certbot-nginx

# 4. Configure swap if low memory and no swap
if ! swapon --show | grep -q .; then
  echo "==> Creating 2G swap"
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
fi

# 5. Secure MariaDB minimally and create DB/user
# Note: this is minimal and not a replacement for proper DB hardening
MYSQL_ROOT_AUTH=$(sudo grep 'temporary password' /var/log/mysqld.log 2>/dev/null || true)
# Create DB and user
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

# 6. Create data root and web root
mkdir -p "$WEB_ROOT"
mkdir -p "$DOL_DATA_ROOT"
chown -R www-data:www-data "$DOL_DATA_ROOT"
chown -R $DEPLOY_USER:$DEPLOY_USER "$WEB_ROOT"

# 7. Clone repository as deploy
if [ ! -d "$WEB_ROOT/.git" ]; then
  echo "==> Cloning repo $REPO_URL into $WEB_ROOT"
  sudo -u $DEPLOY_USER git clone "$REPO_URL" "$WEB_ROOT"
else
  echo "==> Repo already cloned, fetching"
  (cd "$WEB_ROOT" && sudo -u $DEPLOY_USER git fetch --all)
fi
cd "$WEB_ROOT"
sudo -u $DEPLOY_USER git checkout "$BRANCH" || true
sudo -u $DEPLOY_USER git pull origin "$BRANCH" || true

# 8. Composer if composer.json exists
if [ -f "$WEB_ROOT/composer.json" ]; then
  if ! command -v composer >/dev/null 2>&1; then
    echo "==> Installing composer"
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
  fi
  echo "==> Running composer install"
  sudo -u $DEPLOY_USER composer install --no-dev --optimize-autoloader
fi

# 9. Nginx site configuration
NGINX_CONF="/etc/nginx/sites-available/digitalpin"
cat > $NGINX_CONF <<EOF
server {
  listen 80;
  server_name ${DOMAIN};
  root ${WEB_ROOT}/htdocs;
  index index.php index.html index.htm;

  access_log /var/log/nginx/digitalpin.access.log;
  error_log /var/log/nginx/digitalpin.error.log;

  location / {
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
  }

  location ~* \.(css|js|png|jpg|jpeg|gif|svg|woff|woff2|ttf|eot)$ {
    expires 30d;
    add_header Cache-Control "public";
  }
}
EOF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/digitalpin
nginx -t && systemctl reload nginx

# 10. Obtain TLS certificate
if command -v certbot >/dev/null 2>&1; then
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "$LETS_EMAIL" || true
fi

# 11. UFW basic rules
if command -v ufw >/dev/null 2>&1; then
  ufw allow OpenSSH
  ufw allow 'Nginx Full'
  ufw --force enable
fi

# 12. PHP-FPM tuning for small VMs
PHP_POOL_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
if [ -f "$PHP_POOL_CONF" ]; then
  sed -i 's/^pm = .*/pm = dynamic/' "$PHP_POOL_CONF" || true
  sed -i 's/^pm.max_children = .*/pm.max_children = 10/' "$PHP_POOL_CONF" || true
  sed -i 's/^pm.start_servers = .*/pm.start_servers = 2/' "$PHP_POOL_CONF" || true
  sed -i 's/^pm.min_spare_servers = .*/pm.min_spare_servers = 1/' "$PHP_POOL_CONF" || true
  sed -i 's/^pm.max_spare_servers = .*/pm.max_spare_servers = 3/' "$PHP_POOL_CONF" || true
  systemctl restart php${PHP_VERSION}-fpm
fi

# 13. Final permissions
chown -R www-data:www-data "$WEB_ROOT"
chmod -R g+rw "$DOL_DATA_ROOT"

# 14. Smoke tests
echo "==> Smoke tests"
nginx -v || true
php -v || true
systemctl is-active nginx && echo "nginx active" || echo "nginx not active"

echo "Bootstrap finished. Next steps:"
cat <<EOS
1) Point DNS A record ${DOMAIN} -> server IP.
2) Open https://${DOMAIN} in a browser and follow Dolibarr web installer.
   - Set DOL_DATA_ROOT to: ${DOL_DATA_ROOT} when asked
   - DB: host=localhost, name=${DB_NAME}, user=${DB_USER}, pass=(the DB_PASS you provided)
3) After setup, remove any console/serial connections in OCI/Hetzner and disable root login/password auth in SSH.

If you need the script to also add your public key to the deploy user's authorized_keys, rerun with DEPLOY_PUBKEY environment variable set to the public key content and the script will append it to /home/${DEPLOY_USER}/.ssh/authorized_keys.

To run again with a public key appended:
  DEPLOY_PUBKEY="$(cat ~/.ssh/digitalpin_deploy.pub 2>/dev/null || echo '')" \ 
  REPO_URL="$REPO_URL" DOMAIN="$DOMAIN" LETS_EMAIL="$LETS_EMAIL" DB_PASS="$DB_PASS" sudo bash $0
EOS

exit 0
