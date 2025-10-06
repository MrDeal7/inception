#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialize the data directory if needed
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background for initialization
mysqld_safe --skip-networking &

# Wait for MariaDB to be ready for connections
for i in {1..30}; do
    if mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent; then
        break
    fi
    echo "Waiting for MariaDB to be ready... (${i})"
    sleep 1
done

# Run initialization SQL
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
echo "all steps done"

# Stop the background MariaDB process
mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Start MariaDB in the foreground (only once!)
exec mysqld_safe --bind-address=0.0.0.0

