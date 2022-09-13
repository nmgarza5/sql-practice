const { Pool } = require('pg');
const { faker } = require('@faker-js/faker');

const pool = new Pool({
  user: 'odoo',
  password: 'odoo',
});

// generate random integer
const getRandomInt = (min, max) => {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min) + min); // The maximum is exclusive and the minimum is inclusive
}

// generate fake cities
const generateCities = async () => {
  for (let i  = 0; i <=30; i++) {
    let cityName = faker.address.city();
    await pool.query(`
      INSERT INTO cities (name)
      VALUES ($1);
    `, [cityName]);
  }
}

// generate fake users
const generateUsers = async () => {
  for (let i  = 0; i <=10000; i++) {
    let firstName = faker.name.firstName();
    let lastName = faker.name.lastName();
    let address = faker.address.streetAddress()
    await pool.query(`
    INSERT INTO users (first_name, last_name, address, city_id)
    VALUES ($1, $2, $3, $4);
    `, [firstName, lastName, address, getRandomInt(1,30)]);
  }
  pool.end();
}


//seed database in correct order
const seedDatabase = async () => {
  await generateCities()
  await generateUsers()
}

seedDatabase()
