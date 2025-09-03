# Assignee Leads Table - Database Structure & Usage

## Overview
The `assignee_leads` table creates a many-to-many relationship between assignees and leads within campaigns, ensuring proper lead distribution and tracking.

## Database Schema

### Table: `assignee_leads`
```sql
CREATE TABLE assignee_leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    campaign_id INT NOT NULL,           -- References campaigns.id
    assignee_id INT NOT NULL,           -- References users.id (the assignee)
    lead_id INT NOT NULL,               -- References leads.id
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT NOT NULL,           -- References users.id (who made the assignment)
    status ENUM('ACTIVE', 'COMPLETED', 'REASSIGNED') DEFAULT 'ACTIVE',
    notes TEXT
);
```

## Key Features

### 1. **One Lead Per Assignee Per Campaign**
- Each lead can only be assigned to one assignee within a campaign
- Enforced by `UNIQUE KEY unique_lead_assignment (campaign_id, lead_id)`

### 2. **Equal Lead Distribution**
- Leads are automatically distributed equally among assignees
- Algorithm ensures fair workload distribution

### 3. **Status Tracking**
- `ACTIVE`: Lead is currently assigned and being worked on
- `COMPLETED`: Lead assignment has been completed
- `REASSIGNED`: Lead has been reassigned to another assignee

### 4. **Audit Trail**
- Tracks who assigned the lead and when
- Maintains history of all assignments

## Usage Instructions

### Step 1: Create the Table
```bash
# Run the basic table creation
mysql -u root -p < create_assignee_leads_table.sql
```

### Step 2: Equal Distribution (Recommended)
```bash
# Run the equal distribution algorithm
mysql -u root -p < equal_lead_distribution.sql
```

### Step 3: Verify Distribution
```sql
-- Check how leads are distributed
SELECT 
    c.name as campaign_name,
    CONCAT(u.first_name, ' ', u.last_name) as assignee_name,
    COUNT(al.lead_id) as assigned_leads_count
FROM assignee_leads al
JOIN campaigns c ON al.campaign_id = c.id
JOIN users u ON al.assignee_id = u.id
GROUP BY c.id, u.id
ORDER BY c.id, u.id;
```

## API Endpoints (To be implemented)

### 1. **Get Campaign Assignments**
```
GET /campaigns/:id/assignments
```
Returns all lead assignments for a specific campaign.

### 2. **Get Assignee Workload**
```
GET /users/:id/assignments
```
Returns all leads assigned to a specific user.

### 3. **Reassign Lead**
```
POST /leads/:id/reassign
Body: { "new_assignee_id": 123, "notes": "Reassignment reason" }
```

### 4. **Update Assignment Status**
```
PUT /assignments/:id/status
Body: { "status": "COMPLETED", "notes": "Lead converted" }
```

## Business Logic

### Lead Assignment Rules
1. **Equal Distribution**: Leads are distributed as evenly as possible among assignees
2. **One-to-One**: Each lead can only be assigned to one assignee at a time
3. **Campaign Isolation**: Assignments are isolated within each campaign
4. **Status Management**: Track progress from assignment to completion

### Example Distribution
**Campaign: Summer Sales (10 leads, 3 assignees)**
- Assignee 1: 4 leads (10 ÷ 3 = 3.33, rounded up)
- Assignee 2: 3 leads
- Assignee 3: 3 leads

## Benefits

1. **Fair Workload**: Ensures no assignee is overloaded
2. **Clear Accountability**: Each lead has one responsible person
3. **Progress Tracking**: Monitor individual and team performance
4. **Flexibility**: Easy to reassign leads when needed
5. **Audit Trail**: Complete history of all assignments

## Integration with Dashboard

The dashboard can now show:
- **Per Campaign**: How many leads each assignee has
- **Per Assignee**: How many leads they're working on
- **Progress Tracking**: Completion rates per assignee
- **Workload Balance**: Visual representation of lead distribution

## Next Steps

1. **Run the SQL scripts** to create the table and populate it
2. **Update the dashboard** to show assignee-specific metrics
3. **Implement API endpoints** for assignment management
4. **Add UI components** for lead assignment and reassignment
5. **Create reports** showing assignee performance and workload balance

## Troubleshooting

### Common Issues
1. **Foreign Key Errors**: Ensure all referenced IDs exist in their respective tables
2. **Duplicate Assignments**: The unique constraint prevents duplicate lead assignments
3. **Data Inconsistency**: Run the equal distribution script to fix any imbalances

### Verification Queries
```sql
-- Check for orphaned assignments
SELECT * FROM assignee_leads al 
LEFT JOIN campaigns c ON al.campaign_id = c.id 
WHERE c.id IS NULL;

-- Check for duplicate lead assignments
SELECT lead_id, COUNT(*) as assignment_count 
FROM assignee_leads 
GROUP BY lead_id 
HAVING assignment_count > 1;
```
