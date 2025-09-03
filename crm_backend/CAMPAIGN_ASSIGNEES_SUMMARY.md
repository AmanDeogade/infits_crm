# Campaign Assignees System - Quick Summary

## 🎯 **What It Is**
The campaign assignees system allows you to assign **users** (from your users table) to **campaigns** with specific roles.

## 👥 **Users as Assignees**
- **Assignees = Users** from your `users` table
- Each user can be assigned to **multiple campaigns**
- Each campaign can have **multiple users** assigned to it
- Users have different **roles** in each campaign

## 🔗 **Database Structure**
```
users (1) ←→ (many) campaign_assignees (many) ←→ (1) campaigns
```

**Example:**
- User "John Doe" (ID: 2) can be assigned to:
  - Campaign "Summer Sales" as a "caller"
  - Campaign "Product Launch" as a "manager"
  - Campaign "Customer Retention" as a "supervisor"

## 📊 **Available Roles**
- **caller**: Makes calls for the campaign
- **manager**: Oversees the campaign and callers
- **supervisor**: Senior role with additional permissions

## 🚀 **Quick Start**

### 1. **Assign a User to a Campaign**
```javascript
POST /campaign-assignees/assign
{
  "campaign_id": 1,
  "user_id": 2,
  "role_in_campaign": "caller"
}
```

### 2. **Get All Assignees for a Campaign**
```javascript
GET /campaign-assignees/campaign/1
```

### 3. **Get All Campaigns for a User**
```javascript
GET /campaign-assignees/user/2
```

### 4. **Get All Campaigns with Assignee Info**
```javascript
GET /campaigns
// Now includes assignees array and assignee_count
```

## 📋 **Example Response**
```json
{
  "success": true,
  "campaigns": [
    {
      "id": 1,
      "name": "Summer Sales Campaign",
      "total_leads": 150,
      "assignee_count": 3,
      "assignees": [
        {
          "user_id": 2,
          "user_name": "John Doe",
          "user_email": "john@example.com",
          "role_in_campaign": "caller",
          "assigned_at": "2024-01-15T10:30:00Z"
        },
        {
          "user_id": 3,
          "user_name": "Jane Smith",
          "user_email": "jane@example.com",
          "role_in_campaign": "manager",
          "assigned_at": "2024-01-15T11:00:00Z"
        }
      ]
    }
  ]
}
```

## 🔧 **Setup Steps**

1. **Run the migration:**
   ```bash
   mysql -u your_username -p crm_database < migrate_campaign_assignees.sql
   ```

2. **Restart your backend server**

3. **Test the functionality:**
   ```bash
   node test_campaign_assignees.js
   ```

## ✅ **Key Features**
- ✅ Multiple users per campaign
- ✅ Multiple campaigns per user
- ✅ Different roles per assignment
- ✅ Assignment history tracking
- ✅ Soft delete (deactivate) assignments
- ✅ Hard delete assignments
- ✅ Update user roles
- ✅ Get assignee counts
- ✅ Full user details in responses

## 🛡️ **Security**
- All endpoints require JWT authentication
- Only authenticated users can manage assignments
- Assignment history is tracked (who assigned whom)

## 📝 **Usage Examples**

### Assign Multiple Users to One Campaign
```javascript
const users = [
  { user_id: 2, role: 'caller' },
  { user_id: 3, role: 'manager' },
  { user_id: 4, role: 'supervisor' }
];

users.forEach(user => {
  fetch('/campaign-assignees/assign', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` },
    body: JSON.stringify({
      campaign_id: 1,
      user_id: user.user_id,
      role_in_campaign: user.role
    })
  });
});
```

### Get Campaign Team
```javascript
const response = await fetch('/campaign-assignees/campaign/1');
const data = await response.json();
console.log('Campaign team:', data.assignees);
```

### Get User's Workload
```javascript
const response = await fetch('/campaign-assignees/user/2');
const data = await response.json();
console.log('User campaigns:', data.campaigns);
```

This system gives you complete flexibility to manage team assignments for your campaigns! 🎉 