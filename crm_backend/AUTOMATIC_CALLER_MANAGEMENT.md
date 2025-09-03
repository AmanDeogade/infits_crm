# Automatic Caller Management Feature

## Overview
This feature automatically manages the `callers` table based on user roles. When a user is created, updated, or deleted with the role "caller", their record is automatically added, updated, or removed from the `callers` table.

## How It Works

### 1. User Creation (Registration)
When a new user is registered with the role "caller":
- User is created in the `users` table
- **Automatically** creates a corresponding record in the `callers` table
- Caller record is initialized with default values (0 calls, 0 duration, etc.)

### 2. User Role Updates
When a user's role is changed:
- **Role changed TO "caller"**: Automatically adds user to `callers` table
- **Role changed FROM "caller"**: Automatically removes user from `callers` table

### 3. User Updates
When a user's information is updated:
- If role changes to/from "caller", the `callers` table is updated accordingly
- If role remains the same, no changes to `callers` table

### 4. User Deletion
When a user is deleted:
- If the user had "caller" role, they are automatically removed from `callers` table
- If user had other roles, no changes to `callers` table

## API Endpoints

### User Registration (Enhanced)
```
POST /api/auth/register
```
**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "initials": "JD",
  "role": "caller",
  "phone": "+1234567890",
  "country_code": "+1"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "token": "jwt_token_here",
  "user": {
    "id": 5,
    "name": "John Doe",
    "email": "john@example.com",
    "initials": "JD",
    "role": "caller",
    "phone": "+1234567890",
    "country_code": "+1"
  }
}
```

**What happens:**
1. User is created in `users` table
2. Caller record is automatically created in `callers` table
3. Console log: `"Caller record created for user: John Doe (ID: 5)"`

### Update User Role
```
PUT /api/users/:id/role
```
**Request Body:**
```json
{
  "role": "caller"
}
```

**What happens:**
- If changing TO "caller": Creates caller record
- If changing FROM "caller": Deletes caller record

### Update User (Full Update)
```
PUT /api/users/:id
```
**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "initials": "JD",
  "role": "caller",
  "country_code": "+1",
  "reporting_to": 1
}
```

**What happens:**
- If role changes to/from "caller", caller table is updated accordingly

### Delete User
```
DELETE /api/users/:id
```
**What happens:**
- If user had "caller" role, they are removed from `callers` table

### Sync Callers Table (Utility)
```
POST /api/users/sync-callers
```
**Purpose:** Syncs existing users with the callers table (useful for migration)

**Response:**
```json
{
  "success": true,
  "message": "Callers table synced successfully",
  "created": 3,
  "deleted": 1
}
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    initials VARCHAR(10) NOT NULL,
    role ENUM('admin', 'caller', 'marketing', 'manager') NOT NULL DEFAULT 'caller',
    phone VARCHAR(20),
    country_code VARCHAR(10) DEFAULT '+91',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Callers Table
```sql
CREATE TABLE callers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    total_calls INT,
    connected_calls INT,
    not_connected_calls INT,
    total_duration_minutes INT,
    duration_raise_percentage FLOAT,
    first_call_time TIME,
    last_call_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Implementation Details

### Helper Function
```javascript
const manageCallerRecord = async (user, action) => {
    try {
        if (action === 'create') {
            await callerModel.create({
                name: user.name,
                total_calls: 0,
                connected_calls: 0,
                not_connected_calls: 0,
                total_duration_minutes: 0,
                duration_raise_percentage: 0.0,
                first_call_time: null,
                last_call_time: null
            });
            console.log(`Caller record created for user: ${user.name}`);
        } else if (action === 'delete') {
            const callers = await callerModel.findAll();
            const callerRecord = callers.find(caller => caller.name === user.name);
            if (callerRecord) {
                await callerModel.delete(callerRecord.id);
                console.log(`Caller record deleted for user: ${user.name}`);
            }
        }
    } catch (error) {
        console.error(`Error ${action}ing caller record for user ${user.name}:`, error);
        // Don't throw error to avoid breaking the main operation
    }
};
```

### Error Handling
- **Non-blocking errors**: If caller table operations fail, the main user operation still succeeds
- **Logging**: All caller operations are logged for debugging
- **Graceful degradation**: System continues to work even if caller management fails

## Usage Examples

### Creating a Caller User
```javascript
// This will automatically create a caller record
const response = await fetch('/api/auth/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: 'password123',
        initials: 'JS',
        role: 'caller',
        phone: '+9876543210'
    })
});
```

### Changing User Role to Caller
```javascript
// This will automatically add user to callers table
const response = await fetch('/api/users/5/role', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ role: 'caller' })
});
```

### Changing User Role from Caller
```javascript
// This will automatically remove user from callers table
const response = await fetch('/api/users/5/role', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ role: 'manager' })
});
```

### Syncing Existing Data
```javascript
// Use this to sync existing users with callers table
const response = await fetch('/api/users/sync-callers', {
    method: 'POST',
    headers: { 'Authorization': 'Bearer your_token' }
});
```

## Benefits

1. **Automatic Management**: No manual intervention required
2. **Data Consistency**: Ensures users and callers tables stay in sync
3. **Error Resilience**: Main operations don't fail if caller management fails
4. **Audit Trail**: All operations are logged
5. **Migration Support**: Sync utility for existing data
6. **Role Flexibility**: Supports all role changes seamlessly

## Migration Guide

If you have existing users with "caller" role that aren't in the callers table:

1. **Run the sync utility:**
   ```bash
   POST /api/users/sync-callers
   ```

2. **Check the response** to see how many records were created/deleted

3. **Verify the sync** by checking both tables

## Troubleshooting

### Common Issues

1. **Caller record not created:**
   - Check console logs for errors
   - Verify user role is exactly "caller"
   - Check if caller with same name already exists

2. **Caller record not deleted:**
   - Check console logs for errors
   - Verify user name matches exactly
   - Check if caller record exists

3. **Sync not working:**
   - Ensure you have proper authentication
   - Check database permissions
   - Verify both tables exist

### Debugging

Enable detailed logging by checking console output:
```
Caller record created for user: John Doe
Caller record deleted for user: Jane Smith
Error creating caller record for user John Doe: [error details]
``` 