// JWT Configuration Template
// Copy this file to jwt.js and update with your actual JWT secret

const jwtConfig = {
  secret: 'your-super-secret-jwt-key-change-this-in-production',
  expiresIn: '24h',
  algorithm: 'HS256'
};

module.exports = jwtConfig;
