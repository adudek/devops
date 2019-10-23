FROM docker.io/mariadb:latest AS master
COPY config/master.cnf /etc/mysql/conf.d/

FROM mariadb:latest AS slave
COPY config/slave.cnf /etc/mysql/conf.d/

FROM mariadb:latest AS orchestrator
WORKDIR /work
COPY orchestrator.sh ./


FROM master