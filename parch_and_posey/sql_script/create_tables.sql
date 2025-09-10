-- Description: Defines the schema for the Parch and Posey database.
--              This script is run before data is loaded.

-- Drop tables if they exist to ensure a clean slate on re-runs.
DROP TABLE IF EXISTS web_events;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS sales_reps;
DROP TABLE IF EXISTS region;

-- Create the region table
CREATE TABLE region (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

-- Create the sales_reps table
CREATE TABLE sales_reps (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    region_id INTEGER REFERENCES region(id)
);

-- Create the accounts table
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    website VARCHAR(255),
    lat NUMERIC,
    long NUMERIC,
    primary_poc VARCHAR(255),
    sales_rep_id INTEGER REFERENCES sales_reps(id)
);

-- Create the orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(id),
    occurred_at TIMESTAMP,
    standard_qty INTEGER,
    gloss_qty INTEGER,
    poster_qty INTEGER,
    total INTEGER,
    standard_amt_usd NUMERIC,
    gloss_amt_usd NUMERIC,
    poster_amt_usd NUMERIC,
    total_amt_usd NUMERIC
);

-- Create the web_events table
CREATE TABLE web_events (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(id),
    occurred_at TIMESTAMP,
    channel VARCHAR(20)
);
