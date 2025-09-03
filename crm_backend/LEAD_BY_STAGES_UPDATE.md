# Lead by Stages Dashboard Feature - Updated

## Overview
The "Lead by Stages" tile in the dashboard displays assignee lead statistics using the `assignee_leads` table directly, showing each assignee's lead status distribution.

## Recent Update

### 🔄 **Change Made**
- **Before**: Used complex query through `campaign_assignees` table
- **After**: Direct query using `assignee_leads` table
- **Reason**: Simplified data access and improved performance

## Database Tables Used

### 🎯 **Primary Table: `assignee_leads`**
- **Purpose**: Main source of lead assignment data
- **Key Fields**:
  - `assignee_id` - Links to users table
  - `status` - Lead status (Fresh, Active, Won, Loss)
  - `campaign_id` - Links to campaigns table
  - `lead_id` - Links to leads table

### 🔗 **Supporting Table: `users`**
- **Purpose**: Provides assignee names and details
- **Key Fields**:
  - `id` - User ID
  - `name` - Assignee name
  - `role` - User role (caller, manager, supervisor)

## Updated SQL Query

```sql
SELECT 
    u.id as assignee_id,
    u.name as assignee_name,
    COUNT(CASE WHEN al.status = 'Fresh' THEN 1 END) as fresh_leads,
    COUNT(CASE WHEN al.status IN ('Not Connected', 'Interested', 'Commited', 'Call Back', 'Temple Visit', 'Temple Donor') THEN 1 END) as active_leads,
    COUNT(CASE WHEN al.status = 'Won' THEN 1 END) as won_leads,
    COUNT(CASE WHEN al.status IN ('Not Interested', 'Lost') THEN 1 END) as loss_leads
FROM assignee_leads al
JOIN users u ON al.assignee_id = u.id
WHERE u.role IN ('caller', 'manager', 'supervisor')
GROUP BY u.id, u.name
ORDER BY u.name
```

## Data Display

| Column | Description | Source Table | Status Values |
|--------|-------------|--------------|---------------|
| **Assignee** | Assignee Name | `users.name` | - |
| **Fresh** | Fresh leads count | `assignee_leads.status = 'Fresh'` | Fresh |
| **Active** | Active leads count | `assignee_leads.status IN (...)` | Not Connected, Interested, Commited, Call Back, Temple Visit, Temple Donor |
| **Won** | Won leads count | `assignee_leads.status = 'Won'` | Won |
| **Loss** | Lost leads count | `assignee_leads.status IN (...)` | Not Interested, Lost |

## Benefits of This Change

### ✅ **Performance Improvements**
- **Simplified Query**: Removed unnecessary table joins
- **Faster Execution**: Direct access to assignee_leads table
- **Reduced Complexity**: Cleaner, more maintainable code

### ✅ **Data Accuracy**
- **Direct Source**: Uses the actual lead assignment data
- **No Filtering Issues**: Eliminates potential data loss from complex joins
- **Real-time Data**: Reflects current lead assignments

### ✅ **Maintainability**
- **Easier Debugging**: Simpler query structure
- **Clear Logic**: Direct relationship between data and display
- **Future Updates**: Easier to modify and extend

## API Endpoint

### **Endpoint**
```
GET /assignees/lead-stats
```

### **Response Format**
```json
{
  "success": true,
  "assignees": [
    {
      "assignee_id": 1,
      "assignee_name": "John Doe",
      "fresh_leads": 5,
      "active_leads": 12,
      "won_leads": 8,
      "loss_leads": 2
    }
  ]
}
```

## Frontend Integration

### **Dashboard Tile**
- **Location**: `crm_final/lib/dashboard/dashboard_screen.dart`
- **Method**: `fetchAssigneeLeadStats()`
- **Display**: Uses `DashboardTile` widget

### **Data Processing**
```dart
assigneeLeadRows = assignees.map<List<String>>((a) {
  return [
    a['assignee_name'] ?? 'Unknown',     // Assignee Name
    a['fresh_leads'] ?? '0',            // Fresh Leads
    a['active_leads'] ?? '0',           // Active Leads
    a['won_leads'] ?? '0',              // Won Leads
    a['loss_leads'] ?? '0',             // Loss Leads
  ];
}).toList();
```

## Testing

### **Test Script**
- **File**: `crm_backend/test_lead_by_stages.js`
- **Purpose**: Verify updated API endpoint
- **Usage**: `node test_lead_by_stages.js`

### **Test Cases**
1. ✅ API endpoint responds correctly
2. ✅ Returns proper JSON format
3. ✅ Shows data from assignee_leads table
4. ✅ Handles empty data gracefully

## Files Modified

### **Backend**
- `crm_backend/models/assignee_lead.js` - Updated `getAssigneeLeadStatsByStage()` method
- `crm_backend/test_lead_by_stages.js` - New test script

### **Frontend**
- No changes needed - frontend code remains the same

## Migration Notes

### **What Changed**
- **Query Structure**: Simplified from 3-table join to 2-table join
- **Data Source**: Direct access to assignee_leads table
- **Performance**: Improved query execution time

### **What Remains the Same**
- **API Endpoint**: Same URL and response format
- **Frontend Display**: Same dashboard tile appearance
- **Data Categories**: Same status groupings (Fresh, Active, Won, Loss)

## Usage Instructions

1. **Access Dashboard**: Navigate to the main dashboard
2. **View Lead by Stages**: Look for the "Lead by Stages" tile
3. **Read Data**: Each row shows an assignee and their lead statistics
4. **Refresh**: Click the refresh button to update data

## Troubleshooting

### **Common Issues**
1. **No Data Displayed**: Check if assignee_leads table has data
2. **API Errors**: Verify backend server is running
3. **Empty Results**: Ensure users have proper roles (caller, manager, supervisor)

### **Debug Steps**
1. Check browser console for errors
2. Verify API endpoint is accessible
3. Test with sample data
4. Check database connectivity
5. Verify assignee_leads table has records
