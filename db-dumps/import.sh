#!/bin/sh
# Script to create databases according to dump filenames if not yet imported
# Author: Andrew Guk

for file in /db-dumps/*.gz
do
  filename=$(basename $file)
  dbname="${filename%%.*}"

  tablecount=$(mysql --socket=${SOCKET} -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$dbname';" | tail -1)
  if [ "$tablecount" -lt 1 ]
  then
    echo "$dbname -> Creating and importing database"
    mysql --socket=${SOCKET} -e "CREATE DATABASE IF NOT EXISTS $dbname;"
    pv $file | gzip -d | mysql --socket=${SOCKET} $dbname
  else
    echo "$dbname -> Database already exists. Skipping."
  fi
done
