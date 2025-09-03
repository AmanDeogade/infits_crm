# Follow-ups Dashboard Feature

## Overview
The Follow-ups tile in the dashboard displays assignee statistics from the `assignee_leads` table, showing each assignee's lead status distribution.

## Features

### 📊 **Data Display**
- **Assignee Name**: Name of the user assigned to leads
- **Fresh**: Number of leads with "Fresh" status
- **Follow Up**: Number of leads with "Follow Up" status  
- **Done**: Number of leads with "Converted" status
- **Cancel**: Number of leads with "Rejected" status

### 🔄 **Real-time Updates**
- Data is fetched from the backend API
- Automatically refreshes when dashboard is loaded
- Shows loading states during data fetch

### 📱 **Responsive Design**
- Adapts to different screen sizes
- Scrollable content for many assignees
- Clean, modern UI design

## Backend Implementation

### API Endpoint
```
GET /assignees/follow-up-stats
```

### Response Format
```json
{
  "success": true,
  "follow_ups": [
    {
      "assignee_name": "John Doe",
      "fresh_count": 5,
      "not_connected_count": 2,
      "interested_count": 3,
      "follow_up_count": 8,
      "converted_count": 12,
      "rejected_count": 1,
      "do_not_call_count": 0,
      "total_leads": 31
    }
  ]
}
```

### Database Query
The API uses a SQL query that:
- Joins `assignee_leads` with `users` table
- Groups by assignee to get statistics
- Counts leads by status using CASE statements
- Orders by total leads (descending)

## Frontend Implementation

### Dashboard Tile
- **Location**: `crm_final/lib/dashboard/dashboard_screen.dart`
- **Data Fetching**: `fetchFollowUpStats()` method
- **Display**: Uses `DashboardTile` widget with custom headers

### Data Processing
```dart
followUpRows = followUps.map<List<String>>((f) {
  return [
    f['assignee_name'] ?? 'Unknown',     // Assignee Name
    f['fresh_count'] ?? '0',            // Fresh
    f['follow_up_count'] ?? '0',        // Follow Up
    f['converted_count'] ?? '0',        // Done/Converted
    f['rejected_count'] ?? '0',         // Cancel/Rejected
  ];
}).toList();
```

## Status Mapping

| Frontend Display | Database Status | Description |
|------------------|-----------------|-------------|
| Fresh | Fresh | New leads not yet contacted |
| Follow Up | Follow Up | Leads requiring follow-up |
| Done | Converted | Successfully converted leads |
| Cancel | Rejected | Rejected or cancelled leads |

## Error Handling

### Backend Errors
- Database connection issues
- Query execution errors
- Invalid data format

### Frontend Errors
- Network connectivity issues
- API response parsing errors
- Empty data states

## Testing

### Test Script
- **File**: `crm_backend/test_follow_up_stats.js`
- **Purpose**: Verify API endpoint functionality
- **Usage**: `node test_follow_up_stats.js`

### Test Cases
1. ✅ API endpoint responds correctly
2. ✅ Returns proper JSON format
3. ✅ Handles empty data gracefully
4. ✅ Shows correct statistics

## Future Enhancements

### Potential Improvements
- **Filtering**: Filter by date range or campaign
- **Sorting**: Sort by different columns
- **Export**: Export data to CSV/Excel
- **Drill-down**: Click to see detailed lead list
- **Charts**: Visual representation of data

### Additional Features
- **Real-time Updates**: WebSocket for live data
- **Notifications**: Alerts for overdue follow-ups
- **Performance Metrics**: Conversion rates, response times
- **Team Comparison**: Compare assignee performance

## Files Modified

### Backend
- `crm_backend/controllers/assigneeController.js` - Added `getFollowUpStats` method
- `crm_backend/routes/assignees.js` - Added `/follow-up-stats` route
- `crm_backend/test_follow_up_stats.js` - Test script

### Frontend
- `crm_final/lib/dashboard/dashboard_screen.dart` - Updated `fetchFollowUpStats` method
- `crm_final/lib/dashboard/widgets/dashboard_tile.dart` - Added Follow-ups data handling

## Usage Instructions

1. **Access Dashboard**: Navigate to the main dashboard
2. **View Follow-ups**: Look for the "Follow-ups" tile
3. **Read Data**: Each row shows an assignee and their lead statistics
4. **Refresh**: Click the refresh button to update data
5. **Navigate**: Click the arrow button to go to detailed follow-ups screen

## Troubleshooting

### Common Issues
1. **No Data Displayed**: Check if assignee_leads table has data
2. **API Errors**: Verify backend server is running
3. **Network Issues**: Check internet connectivity
4. **Display Issues**: Ensure proper column headers are set

### Debug Steps
1. Check browser console for errors
2. Verify API endpoint is accessible
3. Test with sample data
4. Check database connectivity
