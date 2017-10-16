#!/bin/bash

set -e

RAILS_DB_NAME="${RAILS_DB_NAME:-$POSTGRES_DB}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-SQL
  create user $RAILS_DB_USER;
  grant all privileges on database $RAILS_DB_NAME to $RAILS_DB_USER;
SQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" "$RAILS_DB_NAME" <<-SQL
  alter schema public owner to $RAILS_DB_USER;

  create extension if not exists hstore;
  create extension if not exists pg_trgm;

  update pg_database set encoding = pg_char_to_encoding('UTF8')
  where datname = '$RAILS_DB_NAME' and encoding = pg_char_to_encoding('SQL_ASCII');
SQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" template1 <<-SQL
  create extension if not exists hstore;
  create extension if not exists pg_trgm;
SQL

db_synchronous_commit="off"
db_shared_buffers="256MB"
db_work_mem="10MB"
db_default_text_search_config="pg_catalog.english"
db_wal_level=minimal
db_max_wal_senders=0
db_checkpoint_segments=6
db_logging_collector=off
db_log_min_duration_statement=100

sed -e "s/#\\?listen_addresses *=.*/listen_addresses = '*'/" \
    -e "s/#\\?synchronous_commit *=.*/synchronous_commit = $db_synchronous_commit/" \
    -e "s/#\\?shared_buffers *=.*/shared_buffers = $db_shared_buffers/" \
    -e "s/#\\?work_mem *=.*/work_mem = $db_work_mem/" \
    -e "s/#\\?default_text_search_config *=.*/default_text_search_config = '$db_default_text_search_config'/" \
    -e "s/#\\?max_wal_senders *=.*/max_wal_senders = $db_max_wal_senders/" \
    -e "s/#\\?wal_level *=.*/wal_level = $db_wal_level/" \
    -e "s/#\\?checkpoint_segments *=.*/checkpoint_segments = $db_checkpoint_segments/" \
    -e "s/#\\?logging_collector *=.*/logging_collector = $db_logging_collector/" \
    -e "s/#\\?log_min_duration_statement *=.*/log_min_duration_statement = $db_log_min_duration_statement/" \
    -i $PGDATA/postgresql.conf
