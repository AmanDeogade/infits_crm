require('dotenv').config();
const mysql = require('mysql2');

const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '12345678', // Replace with your actual MySQL password
    database: process.env.DB_NAME || 'crm_database',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

console.log('Database configuration:', {
    host: dbConfig.host,
    user: dbConfig.user,
    database: dbConfig.database,
    password: dbConfig.password ? '[SET]' : '[NOT SET]'
});

const pool = mysql.createPool(dbConfig);

pool.getConnection((err, connection) => {
    if (err) {
        console.error('Database connection failed:', err.message);
        console.log('Please make sure MySQL is running and the database credentials are correct.');
        console.log('You can:');
        console.log('1. Install XAMPP and start MySQL');
        console.log('2. Create the database: CREATE DATABASE crm_database;');
        console.log('3. Import schema.sql file');
    } else {
        console.log('Database connected successfully!');
        connection.release();
    }
});

module.exports = pool.promise();
