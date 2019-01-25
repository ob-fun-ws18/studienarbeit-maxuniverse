FROM mysql:5.7

ENV MYSQL_DATABASE=dynkell \
    MYSQL_ROOT_PASSWORD=metallica

ADD pdns.sql /docker-entrypoint-initdb.d

EXPOSE 3306
