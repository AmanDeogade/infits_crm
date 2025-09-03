# Lead Assignment with User Selection Feature

## Overview
This feature enhances the Add Lead functionality to show all users in the "Assign To" dropdown instead of just callers, and properly updates the `campaign_assignees` and `assignee_leads` tables when a lead is assigned.

## Implementation Details

### 1. Frontend Changes

#### Updated Add Lead Screen
- **File**: `crm_final/lib/home_campaign/add_lead_screen.dart`
- **Changes**:
  - Changed `_fetchAllCallers()` to `_fetchAllUsers()` to fetch all users instead of just callers
  - Updated API endpoint from `/callers` to `/users`
  - Updated UI text from "No callers available" to "No users available"
  - Updated dropdown hint from "---Select---" to "---Select User---"
  - Updated variable names and comments for clarity
  - Added authentication headers to API requests
  - Uses `AuthService.getAuthHeaders()` for proper authentication

### 2. Backend Changes

#### Updated Lead Controller
- **File**: `crm_backend/controllers/leadController.js`
- **Changes**:
  - Added import for `assigneeLeadModel`
  - Enhanced `createLead` function to create entries in `assignee_leads` table
  - Added proper error handling for assignee_lead creation
  - Uses logged-in user's ID for `assigned_by` field (with fallback to admin user)
  - Maintains backward compatibility with unassigned leads

#### Updated Lead Routes
- **File**: `crm_backend/routes/leads.js`
- **Changes**:
  - Added authentication middleware to POST routes
  - Ensures user information is available for `assigned_by` field

#### Database Schema Update
- **File**: `crm_backend/schema.sql`
- **Changes**:
  - Added `assignee_leads` table definition
  - Includes proper foreign key constraints
  - Unique constraint to prevent duplicate assignments

### 3. Database Tables

#### assignee_leads Table
```sql
CREATE TABLE IF NOT EXISTS assignee_leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    assignee_id INT NOT NULL,
    lead_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT NOT NULL,
    status ENUM('Fresh', 'Not Connected', 'Interested', 'Commited', 'Call Back', 'Not Interested', 'Won', 'Lost', 'Temple Visit', 'Temple Donor') DEFAULT 'Fresh',
    notes TEXT,
    
    -- Foreign key constraints
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
    FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Unique constraints to ensure one lead per assignee per campaign
    UNIQUE KEY unique_lead_assignment (campaign_id, lead_id)
);
```

#### Data Population Details
When a lead is assigned to a user, the `assignee_leads` table is populated with:
- **campaign_id**: The ID of the campaign the lead belongs to
- **assignee_id**: The ID of the user assigned to the lead
- **lead_id**: The ID of the lead being created
- **assigned_by**: The ID of the logged-in user who made the assignment
- **assigned_at**: Timestamp of when the assignment was made
- **status**: Default status 'Fresh'
- **notes**: Description of the assignment

### 4. User Flow

1. **Navigate to Add Lead**: User goes to Add Lead screen
2. **Select Campaign**: User selects a campaign from dropdown
3. **Assign To Dropdown**: User sees all users (not just callers) in the "Assign To" dropdown
4. **Select User**: User can select any user to assign the lead to
5. **Save Lead**: When lead is saved:
   - Lead is created in `leads` table
   - If user is selected, they are added to `campaign_assignees` table (if not already there)
   - Lead assignment is recorded in `assignee_leads` table
   - Lead's `assigned_to` field is updated with the campaign_assignee ID

### 5. API Endpoints

#### Get All Users
```
GET /users
```
Returns all users for the assignment dropdown.

#### Create Lead with Assignment
```
POST /leads
```
Body includes `assigned_to` field with user ID.

#### Campaign Assignees
```
GET /campaign-assignees/campaign/:campaignId
```
Returns all assignees for a specific campaign.

### 6. Data Flow

#### When Lead is Assigned:
1. **Frontend**: Sends lead data with `assigned_to` user ID
2. **Backend**: 
   - Creates lead in `leads` table
   - Checks if user is in `campaign_assignees` for the campaign
   - If not, adds user to `campaign_assignees`
   - Creates entry in `assignee_leads` table
   - Updates lead's `assigned_to` field

#### Database Relationships:
- `leads.assigned_to` → `campaign_assignees.id`
- `assignee_leads.assignee_id` → `users.id`
- `assignee_leads.lead_id` → `leads.id`
- `assignee_leads.campaign_id` → `campaigns.id`

### 7. Error Handling

#### Frontend
- Network error handling for API calls
- User-friendly error messages
- Loading states during operations

#### Backend
- Validation of user existence
- Validation of campaign existence
- Proper foreign key constraint handling
- Graceful fallback if assignee_lead creation fails

### 8. Testing

#### Test Script
- **File**: `crm_backend/test_lead_assignment.js`
- **Tests**:
  - Fetch all users
  - Create lead without assignment
  - Create lead with assignment
  - Verify campaign assignees
  - Verify assignee_leads records

#### Manual Testing Steps
1. Start backend server
2. Navigate to Add Lead screen
3. Select a campaign
4. Verify all users appear in "Assign To" dropdown
5. Select a user and create lead
6. Verify lead is assigned correctly
7. Check database tables for proper records

### 9. Benefits

1. **Flexible Assignment**: Any user can be assigned to leads, not just callers
2. **Proper Tracking**: Complete audit trail of lead assignments
3. **Data Integrity**: Foreign key constraints ensure data consistency
4. **Scalable**: Supports multiple assignees per campaign
5. **Backward Compatible**: Existing functionality remains unchanged

## Files Modified/Created

### Modified Files
- `crm_final/lib/home_campaign/add_lead_screen.dart`
- `crm_backend/controllers/leadController.js`
- `crm_backend/schema.sql`

### New Files
- `crm_backend/test_lead_assignment.js`
- `crm_backend/test_assignee_leads_data.js`
- `crm_backend/LEAD_USER_ASSIGNMENT_FEATURE.md`

### Existing Files (No Changes)
- `crm_backend/models/assignee_lead.js`
- `crm_backend/controllers/campaignAssigneeController.js`
- `crm_backend/controllers/userController.js`

## Future Enhancements

1. **Role-based Filtering**: Filter users by role in the dropdown
2. **Assignment History**: Track assignment changes over time
3. **Bulk Assignment**: Assign multiple leads to users at once
4. **Assignment Rules**: Automatic assignment based on workload or skills
5. **Notification System**: Notify users when assigned new leads
6. **Assignment Analytics**: Track assignment effectiveness and performance
