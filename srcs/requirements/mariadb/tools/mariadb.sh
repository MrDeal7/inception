#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialize the data directory if needed
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --skip-networking &
pid="$!"

# Wait for MariaDB to be ready for connections
for i in {1..30}; do
    if mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent; then
        break
    fi
    echo "Waiting for MariaDB to be ready... (${i})"
    sleep 1
done

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
echo "all steps done"

kill "$pid"
wait "$pid"

exec mysqld_safe