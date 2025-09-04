<<<<<<< HEAD
# CRM System - Complete Customer Relationship Management Solution

A comprehensive Customer Relationship Management (CRM) system built with **Flutter** for the frontend and **Node.js/Express** with **MySQL** for the backend. This system provides complete lead management, campaign tracking, user management, and reporting capabilities.

## 📋 Table of Contents

- [Features](#-features)
- [Technology Stack](#-technology-stack)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [Project Structure](#-project-structure)
- [Database Schema](#-database-schema)
- [API Documentation](#-api-documentation)
- [Features Overview](#-features-overview)
- [Usage Guide](#-usage-guide)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🎯 **Core CRM Features**
- **User Management**: Multi-role user system (Admin, Manager, Supervisor, Caller)
- **Lead Management**: Complete lead lifecycle tracking
- **Campaign Management**: Create and manage marketing campaigns
- **Lead Assignment**: Automatic and manual lead distribution
- **Follow-up Tracking**: Track lead status and follow-up activities
- **Reporting & Analytics**: Dashboard with real-time statistics

### 📊 **Advanced Features**
- **Excel Import/Export**: Bulk data import for leads, donations, prasadam, and filter users
- **Lead Distribution**: Automatic round-robin lead assignment
- **Campaign Analytics**: Track campaign performance and lead conversion
- **User Activity Tracking**: Monitor user performance and activities
- **Filter User Management**: Manage and track filter user data
- **Donation Management**: Track donations and donor information
- **Prasadam Management**: Manage prasadam distribution and tracking

### 🎨 **User Interface**
- **Responsive Design**: Works on web, mobile, and desktop
- **Modern UI**: Clean, intuitive interface with Material Design
- **Real-time Updates**: Live data updates and notifications
- **Search & Filter**: Advanced search and filtering capabilities
- **Data Visualization**: Charts and graphs for analytics

## 🛠 Technology Stack

### **Frontend**
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider/SetState
- **UI Components**: Material Design
- **HTTP Client**: http package
- **File Handling**: file_picker, excel packages
- **Local Storage**: shared_preferences

### **Backend**
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MySQL 8.0+
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt
- **File Processing**: multer, excel packages

### **Database**
- **RDBMS**: MySQL
- **Connection Pool**: mysql2
- **Migrations**: Manual SQL scripts

## 📋 Prerequisites

Before installing the project, ensure you have the following installed:

### **Required Software**
- **Node.js** (v18.0.0 or higher)
- **MySQL** (v8.0 or higher)
- **Flutter** (v3.0.0 or higher)
- **Git** (for version control)

### **Development Tools**
- **VS Code** (recommended) or any code editor
- **Postman** or similar API testing tool
- **MySQL Workbench** or similar database management tool

### **System Requirements**
- **RAM**: Minimum 4GB (8GB recommended)
- **Storage**: At least 2GB free space
- **OS**: Windows 10+, macOS 10.15+, or Ubuntu 18.04+

## 🚀 Installation & Setup

### **Step 1: Clone the Repository**

```bash
git clone <repository-url>
cd CRM-Final
```

### **Step 2: Backend Setup**

#### **Install Dependencies**
```bash
cd crm_backend
npm install
```

#### **Database Configuration**
1. Create a MySQL database:
```sql
CREATE DATABASE crm_system;
```

2. Update database configuration in `crm_backend/config/database.js`:
```javascript
const dbConfig = {
  host: 'localhost',
  user: 'your_username',
  password: 'your_password',
  database: 'crm_system',
  port: 3306
};
```

#### **Initialize Database**
```bash
# Run the schema file
mysql -u your_username -p crm_system < schema.sql
```

#### **Start Backend Server**
```bash
npm start
# or for development
npm run dev
```

The backend will start on `http://localhost:3000`

### **Step 3: Frontend Setup**

#### **Install Flutter Dependencies**
```bash
cd crm_final
flutter pub get
```

#### **Configure API Endpoints**
Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000';
```

#### **Run the Application**
```bash
# For web
flutter run -d chrome

# For mobile (Android/iOS)
flutter run

# For desktop
flutter run -d windows  # or macos, linux
```

## 📁 Project Structure

```
CRM-Final/
├── crm_backend/                 # Backend Node.js/Express application
│   ├── config/                  # Configuration files
│   │   ├── database.js          # Database configuration
│   │   └── jwt.js               # JWT configuration
│   ├── controllers/             # Route controllers
│   │   ├── authController.js    # Authentication controller
│   │   ├── campaignController.js # Campaign management
│   │   ├── leadController.js    # Lead management
│   │   ├── userController.js    # User management
│   │   └── ...
│   ├── models/                  # Database models
│   │   ├── user.js              # User model
│   │   ├── campaign.js          # Campaign model
│   │   ├── lead.js              # Lead model
│   │   └── ...
│   ├── routes/                  # API routes
│   │   ├── auth.js              # Authentication routes
│   │   ├── campaigns.js         # Campaign routes
│   │   ├── leads.js             # Lead routes
│   │   └── ...
│   ├── middleware/              # Custom middleware
│   │   └── authenticateToken.js  # JWT authentication
│   ├── schema.sql               # Database schema
│   ├── server.js                # Main server file
│   └── package.json             # Node.js dependencies
│
├── crm_final/                   # Frontend Flutter application
│   ├── lib/
│   │   ├── main.dart            # Main application entry
│   │   ├── services/            # API services
│   │   │   ├── auth_service.dart # Authentication service
│   │   │   ├── api_service.dart  # API client
│   │   │   └── ...
│   │   ├── screens/             # Application screens
│   │   │   ├── auth/            # Authentication screens
│   │   │   ├── dashboard/       # Dashboard screens
│   │   │   ├── home_campaign/   # Campaign management
│   │   │   └── ...
│   │   ├── widgets/             # Reusable widgets
│   │   └── utils/               # Utility functions
│   ├── assets/                 # Static assets
│   ├── pubspec.yaml            # Flutter dependencies
│   └── ...
│
├── docs/                       # Documentation
│   ├── API_DOCUMENTATION.md    # API documentation
│   ├── EXCEL_UPLOAD_STRUCTURES.md # Excel upload formats
│   └── ...
│
└── README.md                   # This file
```

## 🗄 Database Schema

### **Core Tables**

#### **users**
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  initials VARCHAR(10),
  role ENUM('admin', 'manager', 'supervisor', 'caller') NOT NULL,
  phone VARCHAR(20),
  country_code VARCHAR(5),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### **campaigns**
```sql
CREATE TABLE campaigns (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  status ENUM('active', 'inactive', 'completed') DEFAULT 'active',
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);
```

#### **leads**
```sql
CREATE TABLE leads (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(20),
  company VARCHAR(255),
  status ENUM('fresh', 'contacted', 'qualified', 'won', 'lost') DEFAULT 'fresh',
  campaign_id INT,
  assigned_to INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (campaign_id) REFERENCES campaigns(id),
  FOREIGN KEY (assigned_to) REFERENCES campaign_assignees(id)
);
```

#### **campaign_assignees**
```sql
CREATE TABLE campaign_assignees (
  id INT PRIMARY KEY AUTO_INCREMENT,
  campaign_id INT NOT NULL,
  user_id INT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (campaign_id) REFERENCES campaigns(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### **assignee_leads**
```sql
CREATE TABLE assignee_leads (
  id INT PRIMARY KEY AUTO_INCREMENT,
  campaign_id INT NOT NULL,
  assignee_id INT NOT NULL,
  lead_id INT NOT NULL,
  assigned_by INT NOT NULL,
  status ENUM('Fresh', 'Follow Up', 'Done', 'Cancel') DEFAULT 'Fresh',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (campaign_id) REFERENCES campaigns(id),
  FOREIGN KEY (assignee_id) REFERENCES users(id),
  FOREIGN KEY (lead_id) REFERENCES leads(id),
  FOREIGN KEY (assigned_by) REFERENCES users(id)
);
```

### **Additional Tables**
- **filter_users**: Store filter user data
- **donors**: Donor information and donations
- **prasadam**: Prasadam distribution tracking

## 🔌 API Documentation

### **Authentication Endpoints**

#### **POST /auth/register**
Register a new user
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "caller",
  "phone": "+1234567890"
}
```

#### **POST /auth/login**
Login user
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

### **Campaign Endpoints**

#### **GET /campaigns**
Get all campaigns
```json
{
  "success": true,
  "campaigns": [
    {
      "id": 1,
      "name": "Summer Campaign",
      "description": "Summer marketing campaign",
      "status": "active",
      "created_by": 1,
      "created_at": "2024-01-15T10:00:00Z"
    }
  ]
}
```

#### **POST /campaigns**
Create new campaign
```json
{
  "name": "New Campaign",
  "description": "Campaign description",
  "status": "active"
}
```

### **Lead Endpoints**

#### **GET /leads**
Get all leads
```json
{
  "success": true,
  "leads": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "status": "fresh",
      "campaign_id": 1,
      "assigned_to": 1
    }
  ]
}
```

#### **POST /leads**
Create new lead
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "company": "ABC Corp",
  "campaign_id": 1,
  "assigned_to": 1
}
```

### **User Endpoints**

#### **GET /users**
Get all users
```json
{
  "success": true,
  "users": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "caller",
      "phone": "+1234567890"
    }
  ]
}
```

## 🎯 Features Overview

### **1. User Management**
- **Multi-role System**: Admin, Manager, Supervisor, Caller
- **User Registration**: Secure user registration with validation
- **Profile Management**: Update user profiles and settings
- **Role-based Access**: Different permissions for different roles

### **2. Campaign Management**
- **Campaign Creation**: Create and manage marketing campaigns
- **Campaign Assignment**: Assign users to campaigns
- **Campaign Analytics**: Track campaign performance
- **Status Tracking**: Monitor campaign status (active, inactive, completed)

### **3. Lead Management**
- **Lead Creation**: Add leads manually or via Excel import
- **Lead Assignment**: Automatic and manual lead distribution
- **Lead Tracking**: Track lead status and progress
- **Follow-up Management**: Manage follow-up activities

### **4. Excel Import/Export**
- **Bulk Import**: Import leads, donations, prasadam, filter users
- **Template Download**: Download Excel templates
- **Data Validation**: Validate imported data
- **Error Handling**: Comprehensive error reporting

### **5. Dashboard & Analytics**
- **Real-time Statistics**: Live dashboard with key metrics
- **Lead Analytics**: Track lead conversion rates
- **User Performance**: Monitor user activity and performance
- **Campaign Reports**: Generate campaign performance reports

### **6. Filter User Management**
- **Filter User Creation**: Add filter users manually or via Excel
- **Data Management**: Manage filter user data
- **Search & Filter**: Advanced search capabilities
- **Bulk Operations**: Perform bulk operations on filter users

## 📖 Usage Guide

### **Getting Started**

1. **Login**: Use your credentials to login to the system
2. **Dashboard**: View the main dashboard with key metrics
3. **Navigation**: Use the sidebar to navigate between different sections

### **Creating a Campaign**

1. Go to **Campaigns** section
2. Click **Create Campaign**
3. Fill in campaign details (name, description, status)
4. Click **Save**

### **Adding Leads**

#### **Manual Addition**
1. Go to **Leads** section
2. Click **Add Lead**
3. Fill in lead details
4. Assign to a campaign and user
5. Click **Save**

#### **Excel Import**
1. Go to **Import Leads**
2. Upload Excel file with lead data
3. Validate data
4. Click **Import**

### **Managing Follow-ups**

1. Go to **Follow-ups** section
2. View assigned leads
3. Update lead status
4. Add notes and comments
5. Mark as completed

### **User Management**

1. Go to **Users** section
2. View all users
3. Edit user details
4. Assign roles and permissions
5. Manage user status

## 🧪 Testing

### **Backend Testing**

Run the test scripts in the `crm_backend` directory:

```bash
# Test authentication
node test_auth.js

# Test campaign creation
node test_campaign_creation.js

# Test lead distribution
node test_lead_distribution.js

# Test Excel upload features
node test_filter_excel_upload.js
```

### **Frontend Testing**

```bash
# Run Flutter tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### **API Testing**

Use Postman or similar tool to test API endpoints:

1. **Authentication**: Test login/register endpoints
2. **CRUD Operations**: Test create, read, update, delete operations
3. **File Upload**: Test Excel file upload functionality
4. **Error Handling**: Test error scenarios

## 🚀 Deployment

### **Backend Deployment**

#### **Using PM2**
```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start server.js --name crm-backend

# Monitor application
pm2 monit

# View logs
pm2 logs crm-backend
```

#### **Using Docker**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### **Frontend Deployment**

#### **Web Deployment**
```bash
# Build for web
flutter build web

# Deploy to hosting service (Firebase, Netlify, etc.)
```

#### **Mobile Deployment**
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

### **Database Deployment**

1. **Production Database**: Use cloud database service (AWS RDS, Google Cloud SQL)
2. **Backup Strategy**: Implement regular database backups
3. **Security**: Configure database security and access controls

## 🔧 Troubleshooting

### **Common Issues**

#### **Backend Issues**

**Database Connection Error**
```bash
# Check database configuration
# Verify MySQL service is running
sudo systemctl status mysql

# Test database connection
mysql -u username -p database_name
```

**Port Already in Use**
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

#### **Frontend Issues**

**Flutter Dependencies**
```bash
# Clean and get dependencies
flutter clean
flutter pub get
```

**Build Errors**
```bash
# Check Flutter version
flutter --version

# Update Flutter
flutter upgrade
```

### **Error Logs**

Check logs for detailed error information:

```bash
# Backend logs
tail -f crm_backend/logs/app.log

# Flutter logs
flutter logs
```

### **Performance Issues**

1. **Database Optimization**: Add indexes to frequently queried columns
2. **Caching**: Implement Redis for session management
3. **Load Balancing**: Use load balancer for high traffic
4. **CDN**: Use CDN for static assets

## 🤝 Contributing

### **Development Workflow**

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** your changes
5. **Submit** a pull request

### **Code Standards**

- **Backend**: Follow ESLint configuration
- **Frontend**: Follow Dart analysis rules
- **Documentation**: Update documentation for new features
- **Testing**: Add tests for new functionality

### **Commit Guidelines**

Use conventional commit messages:

```
feat: add new feature
fix: fix bug
docs: update documentation
style: formatting changes
refactor: code refactoring
test: add tests
chore: maintenance tasks
```

## 📞 Support

### **Documentation**
- [API Documentation](docs/API_DOCUMENTATION.md)
- [Excel Upload Structures](docs/EXCEL_UPLOAD_STRUCTURES.md)
- [Database Schema](docs/DATABASE_SCHEMA.md)

### **Contact**
- **Email**: support@infits.tech
- **Manager's Number**: +919392718081
- **Linkedin Profile**: https://www.linkedin.com/company/team-infits/

**Made with ❤️ by the Infits Team**
- Aman Deogade
- Prashant Dubey
