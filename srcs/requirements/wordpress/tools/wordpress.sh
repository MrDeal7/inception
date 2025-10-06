#!/bin/sh

sleep 10

if [ -f /var/www/html/wp-config.php ]; then
  echo "WordPress already configured"
else
  echo "Downloading WordPress..."
  wget -q http://wordpress.org/latest.tar.gz -O latest.tar.gz || exit 1
  tar xfz latest.tar.gz
  cp -r wordpress/* .
  cp -r wordpress/.* . 2>/dev/null || true
  rm -rf latest.tar.gz wordpress

  sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config-sample.php
  sed -i "s/username_here/${MYSQL_USER}/" wp-config-sample.php
  sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config-sample.php
  sed -i "s/localhost/${MYSQL_HOSTNAME}/" wp-config-sample.php

  cp wp-config-sample.php /var/www/html/wp-config.php
  chown -R www-data:www-data /var/www/html
fi

if ! wp core is-installed --allow-root; then
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="league" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
fi

wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}" --role=author --allow-root

exec "$@"