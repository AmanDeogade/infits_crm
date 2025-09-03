# Excel Upload Structures Documentation

## Overview
This document provides comprehensive information about the Excel sheet structures used for uploading data in the CRM system. The system supports three main types of Excel uploads: Campaign Leads, Prasadam (Temple Donations), and Donor Forms.

## 📋 **Table of Contents**

1. [Campaign Leads Excel Structure](#campaign-leads-excel-structure)
2. [Prasadam Excel Structure](#prasadam-excel-structure)
3. [Donor Forms Excel Structure](#donor-forms-excel-structure)
4. [Filter Users Excel Structure](#filter-users-excel-structure)
5. [Common Requirements](#common-requirements)
6. [Error Handling](#error-handling)
7. [Best Practices](#best-practices)

---

## 🎯 **Campaign Leads Excel Structure**

### **Purpose**
Upload lead data for marketing campaigns with automatic distribution to callers.

### **Required Columns**

| Column Name | Required | Data Type | Description | Example |
|-------------|----------|-----------|-------------|---------|
| **first_name** | ✅ Yes | Text | Lead's first name | "John" |
| **last_name** | ✅ Yes | Text | Lead's last name | "Doe" |
| **email** | ✅ Yes | Email | Lead's email address | "john.doe@example.com" |
| **phone** | ❌ No | Phone | Primary phone number | "+91 9876543210" |
| **alt_phone** | ❌ No | Phone | Alternative phone number | "+91 8765432109" |
| **address_line** | ❌ No | Text | Street address | "123 Main Street" |
| **city** | ❌ No | Text | City name | "Mumbai" |
| **state** | ❌ No | Text | State/Province | "Maharashtra" |
| **country** | ❌ No | Text | Country name | "India" |
| **zip** | ❌ No | Text | Postal/ZIP code | "400001" |

### **Sample Data**

```csv
first_name,last_name,email,phone,alt_phone,address_line,city,state,country,zip
John,Doe,john.doe@example.com,+91 9876543210,+91 8765432109,123 Main Street,Mumbai,Maharashtra,India,400001
Jane,Smith,jane.smith@example.com,+91 8765432109,,456 Oak Avenue,Delhi,Delhi,India,110001
Bob,Johnson,bob.johnson@example.com,+91 7654321098,+91 6543210987,789 Pine Road,Bangalore,Karnataka,India,560001
Alice,Brown,alice.brown@example.com,+91 6543210987,,321 Elm Street,Chennai,Tamil Nadu,India,600001
Mike,Wilson,mike.wilson@example.com,+91 5432109876,+91 4321098765,654 Maple Drive,Hyderabad,Telangana,India,500001
```

### **Validation Rules**
- **first_name**: Must not be empty
- **last_name**: Must not be empty
- **email**: Must be valid email format
- **phone**: Optional, but if provided should be valid phone format
- **Duplicate Prevention**: System checks for duplicate emails and phones across all campaigns

### **Upload Process**
1. Upload Excel file
2. System validates format and required fields
3. Leads are randomly distributed among selected callers
4. Each lead is assigned to a campaign
5. Duplicate leads are automatically filtered out

---

## 🏛️ **Prasadam Excel Structure**

### **Purpose**
Upload temple donation records for prasadam distribution tracking.

### **Required Columns**

| Column Name | Required | Data Type | Description | Example |
|-------------|----------|-----------|-------------|---------|
| **Name** | ✅ Yes | Text | Donor's full name | "John Doe" |
| **Date** | ✅ Yes | Date | Donation date (DD-MM-YYYY) | "21-05-2025" |
| **Status** | ❌ No | Enum | Verification status | "Verified" / "Not Verified" |
| **Images** | ❌ No | Enum | Images sent status | "Sent" / "Not Sent" |
| **Email** | ❌ No | Enum | Email sent status | "Yes" / "No" |

### **Sample Data**

```csv
Name,Date,Status,Images,Email
John Doe,21-05-2025,Verified,Sent,Yes
Jane Smith,20-01-2024,Not Verified,Not Sent,No
Mike Johnson,25-01-2024,Verified,Sent,Yes
Sarah Wilson,30-01-2024,Not Verified,Not Sent,No
Robert Brown,01-02-2024,Verified,Sent,Yes
```

### **Validation Rules**
- **Name**: Must not be empty
- **Date**: Must be in DD-MM-YYYY format
- **Status**: Defaults to "Not Verified" if empty
- **Images**: Defaults to "Not Sent" if empty
- **Email**: Defaults to "No" if empty

### **Date Format Conversion**
- **Input**: DD-MM-YYYY (e.g., "21-05-2025")
- **Database**: YYYY-MM-DD (e.g., "2025-05-21")
- **System automatically converts the format**

---

## 💰 **Donor Forms Excel Structure**

### **Purpose**
Upload general donation records for donor management.

### **Required Columns**

| Column Name | Required | Data Type | Description | Example |
|-------------|----------|-----------|-------------|---------|
| **Name** | ✅ Yes | Text | Donor's full name | "John Doe" |
| **Date** | ✅ Yes | Date | Donation date (DD-MM-YYYY) | "15-01-2024" |
| **Status** | ❌ No | Enum | Verification status | "Verified" / "Not Verified" |
| **Images** | ❌ No | Enum | Images sent status | "Sent" / "Not Sent" |

### **Sample Data**

```csv
Name,Date,Status,Images
John Doe,15-01-2024,Verified,Sent
Jane Smith,20-01-2024,Not Verified,Not Sent
Mike Johnson,25-01-2024,Verified,Sent
Sarah Wilson,30-01-2024,Not Verified,Not Sent
Robert Brown,01-02-2024,Verified,Sent
```

### **Validation Rules**
- **Name**: Must not be empty
- **Date**: Must be in DD-MM-YYYY format
- **Status**: Defaults to "Not Verified" if empty
- **Images**: Defaults to "Not Sent" if empty

---

## 🚫 **Filter Users Excel Structure**

### **Purpose**
Upload user data for blacklist/filter management.

### **Required Columns**

| Column Name | Required | Data Type | Description | Example |
|-------------|----------|-----------|-------------|---------|
| **Name** | ✅ Yes | Text | User's full name | "John Doe" |
| **Email** | ✅ Yes | Email | User's email address | "john.doe@example.com" |
| **Phone** | ❌ No | Phone | User's phone number | "+91 9876543210" |
| **Date** | ❌ No | Date | Filter date (YYYY-MM-DD) | "2024-01-15" |

### **Sample Data**

```csv
Name,Email,Phone,Date
John Doe,john.doe@example.com,+91 9876543210,2024-01-15
Jane Smith,jane.smith@example.com,+91 8765432109,2024-01-20
Bob Johnson,bob.johnson@example.com,,2024-01-25
Alice Brown,alice.brown@example.com,+91 7654321098,
```

### **Validation Rules**
- **Name**: Must not be empty
- **Email**: Must be valid email format
- **Phone**: Optional
- **Date**: Optional, in YYYY-MM-DD format

---

## 🔧 **Common Requirements**

### **File Format Support**
- **Excel**: .xlsx, .xls
- **CSV**: .csv
- **File Size**: Maximum 10MB
- **Encoding**: UTF-8 recommended

### **Header Requirements**
- **Case Sensitivity**: Column names are case-insensitive
- **Spacing**: Extra spaces are automatically trimmed
- **Special Characters**: Avoid special characters in column names

### **Data Validation**
- **Empty Cells**: Treated as empty strings
- **N/A Values**: Automatically converted to empty strings
- **Whitespace**: Leading/trailing spaces are trimmed
- **Duplicate Rows**: Automatically filtered out

### **Error Handling**
- **Missing Required Fields**: Row skipped with error message
- **Invalid Format**: Row skipped with specific error
- **Duplicate Data**: Automatically filtered out
- **File Size Exceeded**: Upload rejected

---

## ⚠️ **Error Handling**

### **Common Error Messages**

| Error Type | Message | Solution |
|------------|---------|----------|
| **Missing Required Columns** | "Excel file must contain [column] column" | Add missing column to Excel |
| **Invalid Date Format** | "Invalid date format. Expected DD-MM-YYYY" | Use correct date format |
| **Invalid Email** | "Invalid email format" | Check email format |
| **File Too Large** | "File size exceeds 10MB limit" | Reduce file size |
| **Empty File** | "No data found in Excel file" | Add data to Excel |
| **Duplicate Data** | "Duplicate found in database" | Remove duplicate entries |

### **Validation Process**
1. **File Format Check**: Validates file extension and size
2. **Header Validation**: Checks for required columns
3. **Data Validation**: Validates each row's data format
4. **Duplicate Check**: Filters out existing records
5. **Database Insert**: Inserts valid records

---

## 📊 **Best Practices**

### **Excel Preparation**
1. **Use Templates**: Download provided templates when available
2. **Check Headers**: Ensure column names match exactly
3. **Data Formatting**: Use consistent date and phone formats
4. **Remove Duplicates**: Clean data before upload
5. **Test with Small Files**: Test with 5-10 records first

### **Data Quality**
1. **Complete Required Fields**: Fill all mandatory columns
2. **Valid Formats**: Use correct email and phone formats
3. **Consistent Naming**: Use consistent naming conventions
4. **Remove Special Characters**: Avoid special characters in data
5. **Backup Data**: Keep original files as backup

### **Upload Process**
1. **Preview Data**: Review parsed data before upload
2. **Check Errors**: Address any validation errors
3. **Monitor Progress**: Watch for upload completion
4. **Verify Results**: Check uploaded data in system
5. **Keep Records**: Save upload confirmation

---

## 🔄 **Upload Workflows**

### **Campaign Leads Upload**
```
1. Create Campaign → 2. Upload Excel → 3. Select Callers → 4. Distribute Leads → 5. Complete
```

### **Prasadam Upload**
```
1. Navigate to Prasadam → 2. Upload Excel → 3. Validate Data → 4. Import Records → 5. Complete
```

### **Donor Upload**
```
1. Navigate to Donors → 2. Upload Excel → 3. Validate Data → 4. Import Records → 5. Complete
```

### **Filter Users Upload**
```
1. Navigate to Filter Users → 2. Upload Excel → 3. Validate Data → 4. Import Records → 5. Complete
```

---

## 📞 **Support**

### **Troubleshooting Steps**
1. **Check File Format**: Ensure .xlsx, .xls, or .csv
2. **Verify Headers**: Match column names exactly
3. **Validate Data**: Check for format errors
4. **Reduce File Size**: Split large files if needed
5. **Contact Support**: If issues persist

### **Common Issues**
- **Upload Fails**: Check file format and size
- **Data Missing**: Verify required columns
- **Format Errors**: Check date and email formats
- **Duplicate Warnings**: Normal behavior, duplicates are filtered
- **Slow Upload**: Large files may take time

### **Getting Help**
- **Documentation**: Refer to this guide
- **Templates**: Use provided Excel templates
- **Error Messages**: Read specific error details
- **Support Team**: Contact technical support

---

## 📈 **Performance Tips**

### **Large File Uploads**
- **Split Files**: Upload files with 1000+ records in batches
- **Optimize Data**: Remove unnecessary columns
- **Check Network**: Ensure stable internet connection
- **Monitor Progress**: Watch upload progress indicators

### **Data Preparation**
- **Clean Data**: Remove duplicates and invalid entries
- **Standardize Formats**: Use consistent date and phone formats
- **Validate Emails**: Ensure email addresses are valid
- **Check Required Fields**: Fill all mandatory columns

---

*Last Updated: January 2025*
*Version: 1.0*
