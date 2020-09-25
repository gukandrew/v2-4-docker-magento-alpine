FROM jbergstroem/mariadb-alpine

USER root
RUN apk add pv mysql-client gzip --no-cache && \
  rm -f /var/cache/apk/*

EXPOSE 3306
