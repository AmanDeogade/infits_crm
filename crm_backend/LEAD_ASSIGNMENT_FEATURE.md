# Lead Assignment Feature

## Overview
The lead assignment feature allows each lead to be assigned to a specific assignee within the campaign. This enables better lead distribution and tracking of which assignee is responsible for each lead.

## Database Changes

### Leads Table
- Added `assigned_to` column (BIGINT UNSIGNED) that references `campaign_assignees.id`
- Foreign key constraint ensures data integrity
- NULL value indicates unassigned leads

### Schema
```sql
ALTER TABLE leads 
ADD COLUMN assigned_to BIGINT UNSIGNED AFTER campaign_id;

ALTER TABLE leads 
ADD CONSTRAINT fk_lead_assigned_to
FOREIGN KEY (assigned_to) REFERENCES campaign_assignees(id)
ON DELETE SET NULL
ON UPDATE CASCADE;
```

## API Endpoints

### Lead Assignment Endpoints

#### 1. Assign a Lead to an Assignee
```
PUT /api/leads/:lead_id/assign/:assignee_id
```
Assigns a specific lead to a specific assignee within the campaign.

#### 2. Unassign a Lead
```
PUT /api/leads/:lead_id/unassign
```
Removes assignment from a lead (sets `assigned_to` to NULL).

#### 3. Get Leads by Assignee
```
GET /api/leads/assignee/:assignee_id
```
Returns all leads assigned to a specific assignee.

#### 4. Get Unassigned Leads for Campaign
```
GET /api/leads/campaign/:campaign_id/unassigned
```
Returns all unassigned leads for a specific campaign.

#### 5. Bulk Assign Leads
```
POST /api/leads/bulk-assign
```
Body: `{ "lead_ids": [1, 2, 3], "assignee_id": 5 }`
Assigns multiple leads to a single assignee.

### Updated Endpoints

#### Create Lead
```
POST /api/leads
```
Now accepts `assigned_to` field in the request body.

#### Update Lead
```
PUT /api/leads/:id
```
Now accepts `assigned_to` field in the request body.

#### Bulk Create Leads (Enhanced)
```
POST /api/leads/bulk
```
Body: `{ "campaign": 1, "leads": [...], "callers": [2, 3, 4] }`
- Imports leads into the campaign
- **Automatically adds selected callers to campaign_assignees table**
- Returns count of leads imported and assignees added

#### Get Campaigns
```
GET /api/campaigns
GET /api/campaigns/:id
```
Now includes `unassigned_leads` count in the response.

## Import Wizard Integration

### Frontend Flow
1. **Upload Excel/CSV** with lead data
2. **Map fields** to lead properties
3. **Check for duplicates** and validate data
4. **Campaign & Caller Selection**:
   - Select existing campaign or create new one
   - Choose one or multiple callers from the list
5. **Import Process**:
   - Leads are imported to the selected campaign
   - Selected callers are automatically added to `campaign_assignees` table
   - Success dialog shows both lead count and assignee count

### Backend Processing
```javascript
// When bulk importing leads with callers:
{
  "campaign": 1,
  "leads": [
    { "first_name": "John", "email": "john@example.com", ... },
    { "first_name": "Jane", "email": "jane@example.com", ... }
  ],
  "callers": [2, 3, 4]  // Caller IDs to add as assignees
}
```

**Response:**
```javascript
{
  "success": true,
  "inserted_count": 2,
  "error_count": 0,
  "errors": [],
  "assignees_added": 3,
  "assignee_ids": [5, 6, 7]
}
```

## Model Methods

### Lead Model
- `findByAssignee(assigneeId)` - Find leads by assignee
- `findByCampaignAndAssignee(campaignId, assigneeId)` - Find leads by campaign and assignee
- `countByAssignee(assigneeId)` - Count leads assigned to an assignee
- `countUnassignedByCampaignId(campaignId)` - Count unassigned leads in a campaign

## Validation Rules

1. **Assignee Validation**: When assigning a lead, the system validates that the assignee exists and is active for the specific campaign.
2. **Campaign Assignment**: A lead can only be assigned to an assignee who is part of the same campaign.
3. **Null Assignment**: Leads can be unassigned (assigned_to = NULL) to allow for flexible lead management.
4. **Duplicate Prevention**: Callers are only added once to campaign_assignees (no duplicates).

## Usage Examples

### Assigning a Lead
```javascript
// Assign lead ID 123 to assignee ID 456
const response = await fetch('/api/leads/123/assign/456', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' }
});
```

### Creating a Lead with Assignment
```javascript
const leadData = {
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    phone: '+1234567890',
    campaign_id: 1,
    assigned_to: 5,  // Assign to assignee ID 5
    current_status: 'NEW'
};

const response = await fetch('/api/leads', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(leadData)
});
```

### Bulk Import with Caller Assignment
```javascript
const importData = {
    campaign: 1,
    leads: [
        { first_name: 'John', email: 'john@example.com' },
        { first_name: 'Jane', email: 'jane@example.com' }
    ],
    callers: [2, 3, 4]  // These callers will be added to campaign_assignees
};

const response = await fetch('/api/leads/bulk', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(importData)
});
```

### Bulk Assignment
```javascript
const bulkAssignData = {
    lead_ids: [1, 2, 3, 4, 5],
    assignee_id: 7
};

const response = await fetch('/api/leads/bulk-assign', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(bulkAssignData)
});
```

## Migration

To apply this feature to existing databases, run the migration script:

```sql
-- Run migrate_leads_assignment.sql
```

This will:
1. Add the `assigned_to` column to existing leads tables
2. Add the foreign key constraint
3. Create indexes for better performance

## Benefits

1. **Better Lead Distribution**: Managers can assign leads to specific team members
2. **Accountability**: Clear ownership of leads for tracking and reporting
3. **Workload Management**: Balance lead distribution across team members
4. **Performance Tracking**: Measure individual assignee performance
5. **Flexible Assignment**: Support for both manual and automated assignment
6. **Streamlined Import**: Callers are automatically added during lead import
7. **No Duplicates**: Prevents duplicate assignee entries in campaigns

## Error Handling

The system provides clear error messages for:
- Invalid assignee for campaign
- Lead not found
- Assignment validation failures
- Database constraint violations
- Import failures with detailed error reporting 