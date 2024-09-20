import postgres from 'postgres';

// Connect to PostgreSQL
const sql = postgres({
    // by default we use the DNS entry during the docker-compose runs
    host: process.env.DATABASE_HOST || 'postgres_db',
    port: Number(process.env.DATABASE_PORT) || 5432,
    database: process.env.DATABASE || 'reviews',
    username: process.env.DATABASE_USERNAME || 'developer',
    password: process.env.DATABASE_PASSWORD || 'weaksauce',
});

export default sql;
