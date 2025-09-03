// Database Configuration Template
// Copy this file to database.js and update with your actual database credentials

const dbConfig = {
  host: 'localhost',
  user: 'your_username',
  password: 'your_password',
  database: 'crm_system',
  port: 3306,
  connectionLimit: 10,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true
};

module.exports = dbConfig;
