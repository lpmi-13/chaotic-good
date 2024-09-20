#!/bin/bash

psql << EOF
CREATE DATABASE reviews;

CREATE USER developer WITH PASSWORD 'weaksauce';

ALTER ROLE developer SET client_encoding TO 'utf8';
ALTER ROLE developer SET default_transaction_isolation TO 'read committed';
ALTER ROLE developer SET timezone TO 'UTC';

GRANT ALL PRIVILEGES ON DATABASE reviews TO developer;
EOF
