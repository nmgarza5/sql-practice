-- Problem 10:
-- Write SQL statements to create database tables to store the details of users  of a basic ecommerce website.
-- 10.1) Each user has a first name, last name, address and city id to store parent reference . City table
-- has id and name column.
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
    );

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city_id INT NOT NULL REFERENCES cities (id)
    );

-- import grant command. this allows odoo user to insert into database in pad-test.js
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO odoo;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO odoo;
