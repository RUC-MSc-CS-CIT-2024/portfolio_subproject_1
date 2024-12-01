#!/bin/bash

# Import data
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /data/imdb.backup
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /data/omdb_data.backup
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /data/wi.backup

# Run scripts in order
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /scripts/B2_build_movie_db.sql
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /scripts/C2_build_framework.sql
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /scripts/D_functions_and_procedures.sql

touch /tmp/startup_finished
