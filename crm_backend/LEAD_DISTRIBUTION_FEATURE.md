# Lead Distribution Feature

## Overview

The Lead Distribution Feature automatically assigns leads to callers during the bulk import process. When users upload an Excel sheet and select multiple callers in the "Campaign & List Confirmation" step, the system randomly distributes leads among the selected callers.

## How It Works

### 1. Frontend Process
1. **Excel Upload**: User uploads Excel sheet with lead data
2. **Field Mapping**: User maps Excel columns to lead fields
3. **Duplicate Checking**: System checks for existing leads
4. **Campaign & List Confirmation**: 
   - User selects campaign (or creates new one)
   - User selects multiple callers from the dropdown
   - User clicks "Next" to proceed
5. **Lead Distribution**: System automatically distributes leads

### 2. Backend Process
1. **Campaign Assignment**: Selected callers are added to `campaign_assignees` table
2. **Lead Creation**: Leads are created with `campaign_id`
3. **Random Distribution**: Leads are randomly shuffled and distributed among callers
4. **Assignment Records**: Each lead assignment is recorded in `assignee_leads` table

## Key Features

### ✅ **Random Distribution**
- Leads are shuffled randomly before distribution
- Each lead is assigned to exactly one caller
- Callers can receive multiple leads
- Distribution is round-robin (evenly spread)

### ✅ **Data Integrity**
- All relationships properly maintained
- `campaign_assignees` table updated
- `assignee_leads` table populated
- `leads` table updated with assignments

### ✅ **Authentication**
- Uses authenticated user for `assigned_by` field
- Proper JWT token validation
- Fallback to admin user if needed

## API Endpoint

### POST `/leads/bulk`

**Request Body:**
```json
{
  "campaign": 123,
  "leads": [
    {
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "address_line": "123 Main St",
      "city": "New York",
      "state": "NY",
      "country": "USA",
      "zip": "10001",
      "current_status": "NEW"
    }
  ],
  "callers": [1, 2, 3]
}
```

**Response:**
```json
{
  "success": true,
  "inserted_count": 10,
  "error_count": 0,
  "errors": [],
  "assignees_added": 3,
  "assignee_ids": [1, 2, 3],
  "lead_assignments": [
    {
      "lead_id": 101,
      "assignee_id": 1,
      "assignee_name": "John Caller"
    }
  ],
  "distribution_summary": {
    "total_leads": 10,
    "total_callers": 3,
    "leads_per_caller": 4
  }
}
```

## Database Tables

### `campaign_assignees`
- Links users to campaigns
- Created for each selected caller
- Used for lead distribution

### `assignee_leads`
- Links leads to assignees
- Created for each lead assignment
- Tracks assignment history

### `leads`
- Main lead records
- Updated with `assigned_to` field
- Contains campaign association

## Frontend Integration

### Success Dialog
The frontend displays a comprehensive success dialog showing:
- Number of leads imported
- Number of callers added
- Distribution summary
- Individual lead assignments
- Filter user exclusions

### Error Handling
- Duplicate lead detection
- Invalid caller validation
- Campaign creation errors
- Network error handling

## Testing

### Test Script: `test_lead_distribution.js`
Comprehensive test that:
1. Creates test campaign
2. Selects multiple callers
3. Creates test leads
4. Performs bulk import
5. Verifies distribution
6. Checks database tables

### Manual Testing
1. Upload Excel sheet with leads
2. Select multiple callers
3. Complete import process
4. Verify lead assignments
5. Check database records

## Benefits

### 🎯 **Efficiency**
- Automatic lead distribution saves time
- No manual assignment required
- Consistent distribution algorithm

### 📊 **Fairness**
- Random distribution ensures fairness
- Even workload distribution
- No bias in assignments

### 🔄 **Scalability**
- Works with any number of leads
- Works with any number of callers
- Handles large datasets efficiently

### 📈 **Tracking**
- Complete assignment history
- Audit trail for assignments
- Performance metrics

## Future Enhancements

### Potential Improvements
1. **Weighted Distribution**: Assign leads based on caller performance
2. **Geographic Distribution**: Assign leads based on location
3. **Skill-based Assignment**: Match leads to caller expertise
4. **Load Balancing**: Ensure equal workload distribution
5. **Priority Assignment**: Handle high-priority leads differently

### Configuration Options
1. **Distribution Algorithm**: Choose between random, round-robin, or weighted
2. **Assignment Rules**: Define custom assignment criteria
3. **Batch Processing**: Process leads in smaller batches
4. **Retry Logic**: Handle failed assignments gracefully

## Troubleshooting

### Common Issues
1. **No callers selected**: Error message prompts user to select callers
2. **Duplicate leads**: Leads are skipped, error count reported
3. **Invalid caller IDs**: Caller validation prevents invalid assignments
4. **Database errors**: Proper error handling and rollback

### Debug Information
- Detailed console logging
- Assignment tracking
- Performance metrics
- Error reporting

## Security Considerations

### Authentication
- JWT token validation required
- User context for audit trail
- Proper authorization checks

### Data Validation
- Input sanitization
- SQL injection prevention
- Duplicate detection
- Integrity constraints

This feature provides a robust, scalable solution for automatically distributing leads among callers during the bulk import process, ensuring fair and efficient lead assignment while maintaining complete audit trails.
