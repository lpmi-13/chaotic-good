psql << EOF
\c reviews;
CREATE TABLE reviews(
    id         serial primary key,
	created_at timestamp with time zone default current_timestamp,
	updated_at timestamp with time zone,
	deleted_at timestamp with time zone NULL,
	reviewer   VARCHAR(50),
	rating     integer,
	comment    text
);

ALTER TABLE reviews
  OWNER TO developer;

EOF
