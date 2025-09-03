# Donor Management Setup

This document explains how to set up the donor management functionality in the CRM backend.

## Prerequisites

- MySQL database running
- Node.js backend server running
- Database `crm_database` created

## Setup Steps

### 1. Create Donors Table

Run the SQL script to create the donors table:

```bash
mysql -u root -p crm_database < create_donors_table.sql
```

Or manually execute the SQL:

```sql
CREATE TABLE IF NOT EXISTS donors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donor_name VARCHAR(255) NOT NULL,
    donation_date DATE NOT NULL,
    status ENUM('Verified', 'Not Verified') DEFAULT 'Not Verified',
    images ENUM('Sent', 'Not Sent') DEFAULT 'Not Sent',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO donors (donor_name, donation_date, status, images) VALUES 
('John Doe', '2024-01-15', 'Verified', 'Sent'),
('Jane Smith', '2024-01-20', 'Not Verified', 'Not Sent'),
('Mike Johnson', '2024-01-25', 'Verified', 'Sent'),
('Sarah Wilson', '2024-01-30', 'Not Verified', 'Not Sent'),
('Robert Brown', '2024-02-01', 'Verified', 'Sent');
```

### 2. Backend Files

The following files have been created:

- `controllers/donorController.js` - API endpoints for donor operations
- `create_donors_table.sql` - SQL script to create the table
- `test_donors_api.js` - Test script to verify API functionality

### 3. API Endpoints

The donor API provides the following endpoints:

- `GET /donors` - Get all donors
- `POST /donors` - Create a new donor
- `PUT /donors/:id` - Update a donor
- `DELETE /donors/:id` - Delete a donor
- `GET /donors/search/name?name=...` - Search donors by name
- `GET /donors/status/:status` - Get donors by status
- `GET /donors/images/:imagesStatus` - Get donors by images status

### 4. Test the API

Run the test script to verify the API is working:

```bash
node test_donors_api.js
```

### 5. Frontend Integration

The Flutter app has been updated to:

- Use the `DonorService` for API calls
- Save donor data to the database when adding new donors
- Load donor data from the database instead of mock data

## Data Structure

Each donor record contains:

- `id` - Unique identifier (auto-increment)
- `donor_name` - Name of the donor
- `donation_date` - Date of donation (YYYY-MM-DD format)
- `status` - Verification status ('Verified' or 'Not Verified')
- `images` - Images status ('Sent' or 'Not Sent')
- `created_at` - Timestamp when record was created
- `updated_at` - Timestamp when record was last updated

## Troubleshooting

### Common Issues

1. **Table not found**: Make sure you've run the SQL script to create the table
2. **Connection refused**: Ensure MySQL is running and accessible
3. **Permission denied**: Check MySQL user permissions
4. **API not responding**: Verify the backend server is running and the donor routes are registered

### Verification

To verify everything is working:

1. Check if the table exists: `SHOW TABLES LIKE 'donors';`
2. Check table structure: `DESCRIBE donors;`
3. Check sample data: `SELECT * FROM donors;`
4. Test API endpoints using the test script or Postman

## Next Steps

After setup, you can:

- Add more donor fields as needed
- Implement donor search and filtering
- Add donor analytics and reporting
- Integrate with other CRM modules



