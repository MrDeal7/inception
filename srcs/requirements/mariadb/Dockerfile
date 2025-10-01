FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client vim gosu \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 777 /var/run/mysqld

RUN mkdir -p /var/lib/mysql \
    && chown -R mysql:mysql /var/lib/mysql \
    && chmod 755 /var/lib/mysql

EXPOSE 3306

COPY ./conf/mysql.conf /etc/mysql/mariadb.conf.d/50-custom.cnf
COPY ./tools/mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]

CMD ["mysqld", "--bind-address=0.0.0.0"]