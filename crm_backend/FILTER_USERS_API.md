# Filter Users API Documentation

## Overview
The Filter Users API provides endpoints to manage filter users with attributes: Name, Email, Phone, and Date. All endpoints require authentication.

## Base URL
```
http://localhost:3000/api/filter-users
```

## Authentication
All endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### 1. Get All Filter Users
**GET** `/api/filter-users`

Returns all filter users ordered by creation date (newest first).

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Filter",
      "email": "john.filter@example.com",
      "phone": "+1234567890",
      "date": "2024-01-15",
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  ],
  "message": "Filter users retrieved successfully"
}
```

### 2. Get Filter User by ID
**GET** `/api/filter-users/:id`

Returns a specific filter user by their ID.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Filter",
    "email": "john.filter@example.com",
    "phone": "+1234567890",
    "date": "2024-01-15",
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T10:00:00.000Z"
  },
  "message": "Filter user retrieved successfully"
}
```

### 3. Create Filter User
**POST** `/api/filter-users`

Creates a new filter user.

**Request Body:**
```json
{
  "name": "John Filter",
  "email": "john.filter@example.com",
  "phone": "+1234567890",
  "date": "2024-01-15T10:00:00.000Z"
}
```

**Required Fields:** `name`, `email`
**Optional Fields:** `phone`, `date`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Filter",
    "email": "john.filter@example.com",
    "phone": "+1234567890",
    "date": "2024-01-15",
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T10:00:00.000Z"
  },
  "message": "Filter user created successfully"
}
```

### 4. Update Filter User
**PUT** `/api/filter-users/:id`

Updates an existing filter user.

**Request Body:**
```json
{
  "name": "Updated Name",
  "phone": "+9876543210"
}
```

All fields are optional for updates.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Updated Name",
    "email": "john.filter@example.com",
    "phone": "+9876543210",
    "date": "2024-01-15",
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T11:00:00.000Z"
  },
  "message": "Filter user updated successfully"
}
```

### 5. Delete Filter User
**DELETE** `/api/filter-users/:id`

Deletes a filter user by ID.

**Response:**
```json
{
  "success": true,
  "message": "Filter user deleted successfully"
}
```

### 6. Search by Email
**GET** `/api/filter-users/search/email?email=john.filter@example.com`

Searches for filter users by exact email match.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Filter",
      "email": "john.filter@example.com",
      "phone": "+1234567890",
      "date": "2024-01-15",
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  ],
  "message": "Filter users found successfully"
}
```

### 7. Search by Date Range
**GET** `/api/filter-users/search/date-range?startDate=2024-01-01&endDate=2024-01-31`

Searches for filter users within a date range.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Filter",
      "email": "john.filter@example.com",
      "phone": "+1234567890",
      "date": "2024-01-15",
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  ],
  "message": "Filter users found successfully"
}
```

### 8. Search by Name
**GET** `/api/filter-users/search/name?name=John`

Searches for filter users by name (partial match).

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Filter",
      "email": "john.filter@example.com",
      "phone": "+1234567890",
      "date": "2024-01-15",
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  ],
  "message": "Filter users found successfully"
}
```

### 9. Bulk Create Filter Users
**POST** `/api/filter-users/bulk`

Creates multiple filter users at once.

**Request Body:**
```json
{
     "users": [
     {
       "name": "User 1",
       "email": "user1@example.com",
       "phone": "+1111111111",
       "date": "2024-01-15T10:00:00.000Z"
     },
     {
       "name": "User 2",
       "email": "user2@example.com",
       "phone": "+2222222222",
       "date": "2024-01-16T10:00:00.000Z"
     }
   ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "insertIds": [1, 2]
  },
  "message": "2 filter users created successfully"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Name and email are required fields"
}
```

### 401 Unauthorized
```json
{
  "error": "Access token required"
}
```

### 403 Forbidden
```json
{
  "error": "Invalid or expired token"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Filter user not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error",
  "error": "Error details"
}
```

## Validation Rules

1. **Name**: Required, string
2. **Email**: Required, valid email format
3. **Phone**: Optional, string
4. **Date**: Optional, valid datetime format (YYYY-MM-DD HH:MM:SS). If not provided, current datetime will be used automatically.

## Database Schema

```sql
CREATE TABLE filter_users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Testing

Run the test file to verify all endpoints:
```bash
node test_filter_users_api.js
```

## Usage Examples

### JavaScript/Node.js
```javascript
const axios = require('axios');

// Login to get token
const loginResponse = await axios.post('http://localhost:3000/auth/login', {
  email: 'admin@example.com',
  password: 'password'
});

const token = loginResponse.data.token;

// Create a filter user
const createResponse = await axios.post('http://localhost:3000/api/filter-users', {
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  date: '2024-01-15'
}, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

console.log(createResponse.data);
```

### cURL
```bash
# Login
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}'

# Create filter user
curl -X POST http://localhost:3000/api/filter-users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"name":"John Doe","email":"john@example.com","phone":"+1234567890","date":"2024-01-15T10:00:00.000Z"}'
``` 