# Prasad Table Setup Guide

## 🗄️ Database Setup

### 1. Create the Prasad Table
Run the SQL script to create the prasad table:

```bash
mysql -u root -p crm_database < create_prasad_table.sql
```

Or manually execute in MySQL:

```sql
CREATE TABLE IF NOT EXISTS prasad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donor_name VARCHAR(255) NOT NULL,
    donation_date DATE NOT NULL,
    status ENUM('Verified', 'Not Verified') DEFAULT 'Not Verified',
    images ENUM('Sent', 'Not Sent') DEFAULT 'Not Sent',
    email ENUM('Yes', 'No') DEFAULT 'No',
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 2. Insert Sample Data
```sql
INSERT INTO prasad (donor_name, donation_date, status, images, email) VALUES
('John Doe', '2024-01-15', 'Verified', 'Sent', 'Yes'),
('Jane Smith', '2024-01-20', 'Not Verified', 'Not Sent', 'No'),
('Mike Johnson', '2024-01-25', 'Verified', 'Sent', 'Yes'),
('Sarah Wilson', '2024-01-30', 'Not Verified', 'Not Sent', 'No'),
('Robert Brown', '2024-02-01', 'Verified', 'Sent', 'Yes');
```

## 🚀 Backend Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Start the Server
```bash
npm start
```

### 3. Test the API
```bash
node test_prasad_api.js
```

## 📱 Frontend Integration

### 1. Import PrasadService
```dart
import '../services/prasad_service.dart';
```

### 2. Use PrasadService Methods
```dart
// Get all prasad records
final prasadRecords = await PrasadService.getAllPrasad(token);

// Create new prasad record
final newPrasad = await PrasadService.createPrasad(
  token,
  'Donor Name',
  '2025-05-21',
  'Verified',
  'Sent',
  'Yes'
);

// Update prasad record
final updatedPrasad = await PrasadService.updatePrasad(
  token,
  id,
  {'donor_name': 'New Name'}
);

// Delete prasad record
final deleted = await PrasadService.deletePrasad(token, id);
```

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/prasad` | Get all prasad records |
| POST | `/prasad` | Create new prasad record |
| PUT | `/prasad/:id` | Update prasad record |
| DELETE | `/prasad/:id` | Delete prasad record |
| GET | `/prasad/search/name?name=query` | Search by donor name |
| GET | `/prasad/status/:status` | Filter by status |
| GET | `/prasad/images/:imagesStatus` | Filter by images status |
| GET | `/prasad/email/:emailStatus` | Filter by email status |

## 📊 Data Structure

```json
{
  "id": 1,
  "donor_name": "John Doe",
  "donation_date": "2024-01-15",
  "status": "Verified",
  "images": "Sent",
  "email": "Yes",
  "created_on": "2024-01-15T00:00:00.000Z",
  "updated_on": "2024-01-15T00:00:00.000Z"
}
```

## 🔧 Configuration

### Environment Variables
- `DB_HOST`: MySQL host (default: localhost)
- `DB_USER`: MySQL username (default: root)
- `DB_PASSWORD`: MySQL password
- `DB_NAME`: Database name (default: crm_database)
- `PORT`: Server port (default: 3000)

## ✅ Verification

1. **Database**: Table created with sample data
2. **Backend**: Server running on port 3000
3. **API**: All endpoints responding correctly
4. **Frontend**: PrasadService integrated and working

## 🐛 Troubleshooting

### Common Issues:
1. **Database Connection**: Check MySQL credentials and connection
2. **Port Conflicts**: Ensure port 3000 is available
3. **Missing Dependencies**: Run `npm install`
4. **Table Not Found**: Execute the SQL script manually

### Debug Commands:
```bash
# Check server status
curl http://localhost:3000/health

# Test prasad API
curl http://localhost:3000/prasad

# Check database connection
mysql -u root -p -e "USE crm_database; SHOW TABLES;"
```

## 📝 Notes

- The prasad table includes an additional `email` field compared to the donors table
- All CRUD operations are supported with proper error handling
- The API follows RESTful conventions
- Authentication is required for all operations (Bearer token)
- Date format should be YYYY-MM-DD for MySQL compatibility



