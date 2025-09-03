# Quick Start Guide

## 🚀 Get Up and Running in 10 Minutes

This guide will help you set up the CRM system quickly for development.

## Prerequisites Check

Before starting, ensure you have:

- ✅ Node.js 18+ installed
- ✅ MySQL 8.0+ installed and running
- ✅ Flutter 3.0+ installed
- ✅ Git installed

## Step 1: Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd CRM-Final

# Check the structure
ls -la
```

## Step 2: Backend Setup (5 minutes)

```bash
# Navigate to backend
cd crm_backend

# Install dependencies
npm install

# Create database
mysql -u root -p -e "CREATE DATABASE crm_system;"

# Import schema
mysql -u root -p crm_system < schema.sql

# Start the server
npm start
```

**Expected Output:**
```
Server running on http://localhost:3000
Database connected successfully!
```

## Step 3: Frontend Setup (3 minutes)

```bash
# Open new terminal
cd crm_final

# Install Flutter dependencies
flutter pub get

# Run the application
flutter run -d chrome
```

**Expected Output:**
```
Flutter run key commands.
r Hot reload. 🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

## Step 4: First Login (2 minutes)

1. **Open browser** and go to `http://localhost:3000`
2. **Register** a new user:
   - Name: `Admin User`
   - Email: `admin@example.com`
   - Password: `password123`
   - Role: `admin`
3. **Login** with your credentials
4. **Explore** the dashboard

## 🎯 Quick Test

### Test Backend API

```bash
# Test authentication
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "role": "caller"
  }'
```

### Test Frontend

1. **Create a Campaign**:
   - Go to Campaigns section
   - Click "Create Campaign"
   - Fill in details and save

2. **Add a Lead**:
   - Go to Leads section
   - Click "Add Lead"
   - Fill in lead details and save

3. **Check Dashboard**:
   - View real-time statistics
   - Verify data appears correctly

## 🔧 Common Issues & Solutions

### Backend Issues

**Port 3000 already in use:**
```bash
# Find and kill the process
lsof -ti:3000 | xargs kill -9
```

**Database connection failed:**
```bash
# Check MySQL status
sudo systemctl status mysql

# Start MySQL if needed
sudo systemctl start mysql
```

**Module not found:**
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Frontend Issues

**Flutter dependencies error:**
```bash
# Clean and get dependencies
flutter clean
flutter pub get
```

**Build errors:**
```bash
# Check Flutter version
flutter --version

# Update Flutter
flutter upgrade
```

## 📱 Development Workflow

### Backend Development

```bash
# Start in development mode with auto-reload
npm run dev

# Run tests
node test_auth.js
node test_campaign_creation.js
```

### Frontend Development

```bash
# Hot reload for development
flutter run -d chrome --hot

# Run tests
flutter test
```

### Database Development

```bash
# Connect to database
mysql -u root -p crm_system

# View tables
SHOW TABLES;

# Check data
SELECT * FROM users LIMIT 5;
```

## 🧪 Testing Features

### Test Excel Upload

1. **Create test Excel file** (`test_leads.xlsx`):
   ```
   Name,Email,Phone,Company
   John Doe,john@example.com,+1234567890,ABC Corp
   Jane Smith,jane@example.com,+1234567891,XYZ Corp
   ```

2. **Upload via UI**:
   - Go to Import Leads
   - Upload the Excel file
   - Verify data appears

### Test Lead Distribution

1. **Create multiple users** with different roles
2. **Assign users to campaign**
3. **Import leads** and verify automatic distribution

### Test Dashboard

1. **Create test data** (campaigns, leads, users)
2. **Check dashboard tiles** update correctly
3. **Verify statistics** are accurate

## 🔍 Debugging

### Backend Debugging

```bash
# Enable debug logging
DEBUG=* npm start

# Check logs
tail -f logs/app.log
```

### Frontend Debugging

```bash
# Enable debug mode
flutter run -d chrome --debug

# Check console logs in browser DevTools
```

### Database Debugging

```sql
-- Check recent activity
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;

-- Check foreign key relationships
SELECT 
  TABLE_NAME,
  COLUMN_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'crm_system';
```

## 📊 Sample Data

### Quick Data Setup

```sql
-- Insert sample users
INSERT INTO users (name, email, password, role) VALUES
('Admin User', 'admin@example.com', '$2a$10$hash', 'admin'),
('Manager User', 'manager@example.com', '$2a$10$hash', 'manager'),
('Caller User', 'caller@example.com', '$2a$10$hash', 'caller');

-- Insert sample campaign
INSERT INTO campaigns (name, description, created_by) VALUES
('Test Campaign', 'Sample campaign for testing', 1);

-- Insert sample leads
INSERT INTO leads (name, email, phone, campaign_id) VALUES
('John Doe', 'john@example.com', '+1234567890', 1),
('Jane Smith', 'jane@example.com', '+1234567891', 1);
```

## 🚀 Production Setup

### Environment Variables

Create `.env` file in `crm_backend`:

```env
NODE_ENV=production
PORT=3000
DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=crm_system
JWT_SECRET=your_jwt_secret
```

### Build Commands

```bash
# Backend production build
npm run build

# Frontend production build
flutter build web --release
```

## 📚 Next Steps

1. **Read the full documentation**:
   - [API Documentation](API_DOCUMENTATION.md)
   - [Database Schema](DATABASE_SCHEMA.md)
   - [Main README](../README.md)

2. **Explore the codebase**:
   - Backend: `crm_backend/` directory
   - Frontend: `crm_final/lib/` directory

3. **Run comprehensive tests**:
   ```bash
   # Backend tests
   cd crm_backend && npm test

   # Frontend tests
   cd crm_final && flutter test
   ```

4. **Join the community**:
   - Report issues on GitHub
   - Contribute to the project
   - Share feedback and suggestions

## 🆘 Need Help?

- **Documentation**: Check the docs folder
- **Issues**: Create GitHub issue
- **Community**: Join our Discord/Slack
- **Email**: support@crm-system.com

---

**Happy Coding! 🎉**

*This guide should get you up and running in under 10 minutes. If you encounter any issues, check the troubleshooting section or reach out for help.*
