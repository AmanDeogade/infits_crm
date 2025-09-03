# API Documentation

## Overview

This document provides comprehensive documentation for the CRM System API endpoints. The API is built using Node.js/Express and follows RESTful conventions.

## Base URL

```
http://localhost:3000
```

## Authentication

Most endpoints require authentication using JWT tokens. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Response Format

All API responses follow this standard format:

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data
  }
}
```

Error responses:

```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

## Endpoints

### Authentication

#### POST /auth/register
Register a new user

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
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
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "caller",
      "initials": "JD"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### POST /auth/login
Login user

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "caller"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Users

#### GET /users
Get all users (requires authentication)

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "role": "caller",
        "phone": "+1234567890",
        "initials": "JD",
        "created_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### GET /users/:id
Get user by ID

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "caller",
      "phone": "+1234567890",
      "initials": "JD"
    }
  }
}
```

#### PUT /users/:id
Update user

**Request Body:**
```json
{
  "name": "John Updated",
  "phone": "+1234567891",
  "role": "supervisor"
}
```

#### DELETE /users/:id
Delete user

### Campaigns

#### GET /campaigns
Get all campaigns

**Response:**
```json
{
  "success": true,
  "data": {
    "campaigns": [
      {
        "id": 1,
        "name": "Summer Campaign",
        "description": "Summer marketing campaign",
        "status": "active",
        "created_by": 1,
        "created_at": "2024-01-15T10:00:00Z",
        "updated_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### POST /campaigns
Create new campaign (requires authentication)

**Request Body:**
```json
{
  "name": "New Campaign",
  "description": "Campaign description",
  "status": "active"
}
```

#### PUT /campaigns/:id
Update campaign

#### DELETE /campaigns/:id
Delete campaign

### Leads

#### GET /leads
Get all leads

**Query Parameters:**
- `campaign_id`: Filter by campaign
- `status`: Filter by status
- `assigned_to`: Filter by assigned user

**Response:**
```json
{
  "success": true,
  "data": {
    "leads": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "company": "ABC Corp",
        "status": "fresh",
        "campaign_id": 1,
        "assigned_to": 1,
        "created_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### POST /leads
Create new lead (requires authentication)

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "company": "ABC Corp",
  "campaign_id": 1,
  "assigned_to": 1
}
```

#### POST /leads/bulk
Bulk create leads (requires authentication)

**Request Body:**
```json
{
  "leads": [
    {
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "company": "ABC Corp"
    },
    {
      "name": "Jane Smith",
      "email": "jane@example.com",
      "phone": "+1234567891",
      "company": "XYZ Corp"
    }
  ],
  "campaign_id": 1,
  "assignees": [1, 2, 3]
}
```

#### PUT /leads/:id
Update lead

#### DELETE /leads/:id
Delete lead

### Campaign Assignees

#### GET /campaign-assignees
Get campaign assignees

**Query Parameters:**
- `campaign_id`: Filter by campaign

**Response:**
```json
{
  "success": true,
  "data": {
    "assignees": [
      {
        "id": 1,
        "campaign_id": 1,
        "user_id": 1,
        "user": {
          "name": "John Doe",
          "email": "john@example.com",
          "role": "caller"
        },
        "is_active": true,
        "assigned_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### POST /campaign-assignees
Assign user to campaign (requires authentication)

**Request Body:**
```json
{
  "campaign_id": 1,
  "user_id": 1
}
```

#### DELETE /campaign-assignees/:id
Remove user from campaign

### Assignee Leads

#### GET /assignee-leads
Get assignee leads

**Query Parameters:**
- `assignee_id`: Filter by assignee
- `campaign_id`: Filter by campaign
- `status`: Filter by status

**Response:**
```json
{
  "success": true,
  "data": {
    "assignee_leads": [
      {
        "id": 1,
        "campaign_id": 1,
        "assignee_id": 1,
        "lead_id": 1,
        "assigned_by": 1,
        "status": "Fresh",
        "notes": "Initial contact made",
        "created_at": "2024-01-15T10:00:00Z",
        "lead": {
          "name": "John Doe",
          "email": "john@example.com",
          "phone": "+1234567890"
        },
        "assignee": {
          "name": "John Caller",
          "email": "caller@example.com"
        }
      }
    ]
  }
}
```

#### POST /assignee-leads
Create assignee lead (requires authentication)

**Request Body:**
```json
{
  "campaign_id": 1,
  "assignee_id": 1,
  "lead_id": 1,
  "status": "Fresh",
  "notes": "Initial assignment"
}
```

#### PUT /assignee-leads/:id
Update assignee lead

### Filter Users

#### GET /filter-users
Get filter users

**Query Parameters:**
- `search`: Search by name or email
- `date`: Filter by date

**Response:**
```json
{
  "success": true,
  "data": {
    "filter_users": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "date": "2024-01-15",
        "created_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### POST /filter-users
Create filter user (requires authentication)

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "date": "2024-01-15"
}
```

### Donors

#### GET /donors
Get donors

**Response:**
```json
{
  "success": true,
  "data": {
    "donors": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "amount": 100.00,
        "donation_date": "2024-01-15",
        "status": "verified",
        "created_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### POST /donors
Create donor (requires authentication)

### Prasadam

#### GET /prasadam
Get prasadam records

**Response:**
```json
{
  "success": true,
  "data": {
    "prasadam": [
      {
        "id": 1,
        "donor_name": "John Doe",
        "donation_date": "2024-01-15",
        "status": "verified",
        "images": "sent",
        "email": "yes",
        "created_at": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

#### POST /prasadam
Create prasadam record (requires authentication)

### Dashboard Analytics

#### GET /assignees/follow-up-stats
Get follow-up statistics

**Response:**
```json
{
  "success": true,
  "data": {
    "assignees": [
      {
        "assignee_name": "John Doe",
        "fresh_leads": 10,
        "follow_up_leads": 5,
        "done_leads": 3,
        "cancel_leads": 2
      }
    ]
  }
}
```

#### GET /assignees/lead-stats
Get lead statistics by stage

**Response:**
```json
{
  "success": true,
  "data": {
    "assignees": [
      {
        "assignee_name": "John Doe",
        "fresh_leads": 10,
        "active_leads": 5,
        "won_leads": 3,
        "loss_leads": 2
      }
    ]
  }
}
```

## Error Codes

| Code | Description |
|------|-------------|
| `AUTH_REQUIRED` | Authentication required |
| `INVALID_TOKEN` | Invalid or expired token |
| `USER_NOT_FOUND` | User not found |
| `EMAIL_EXISTS` | Email already exists |
| `INVALID_CREDENTIALS` | Invalid login credentials |
| `VALIDATION_ERROR` | Request validation failed |
| `DATABASE_ERROR` | Database operation failed |
| `FILE_UPLOAD_ERROR` | File upload failed |
| `PERMISSION_DENIED` | Insufficient permissions |

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

- **Authentication endpoints**: 5 requests per minute
- **Other endpoints**: 100 requests per minute

## File Upload

### Excel File Upload

Supported formats: `.xlsx`, `.xls`, `.csv`

**Maximum file size**: 10MB

**Headers:**
```
Content-Type: multipart/form-data
Authorization: Bearer <token>
```

**Request Body:**
```
file: <excel-file>
```

## WebSocket Events

For real-time updates, the API supports WebSocket connections:

### Events

- `lead_created`: New lead created
- `lead_updated`: Lead status updated
- `campaign_updated`: Campaign status changed
- `user_activity`: User activity logged

### Connection

```javascript
const socket = io('http://localhost:3000');

socket.on('lead_created', (data) => {
  console.log('New lead:', data);
});
```

## Testing

### Test Endpoints

Use the provided test scripts in the `crm_backend` directory:

```bash
# Test authentication
node test_auth.js

# Test campaign creation
node test_campaign_creation.js

# Test lead distribution
node test_lead_distribution.js
```

### Postman Collection

Import the provided Postman collection for API testing:

```
CRM_API_Collection.json
```

## Versioning

API versioning is handled through URL prefixes:

- Current version: `/api/v1/`
- Future versions: `/api/v2/`

## Deprecation Policy

- Endpoints will be marked as deprecated 6 months before removal
- Deprecated endpoints will return a warning header
- New versions will be released quarterly

## Support

For API support and questions:

- **Email**: api-support@crm-system.com
- **Documentation**: https://docs.crm-system.com/api
- **Status Page**: https://status.crm-system.com
