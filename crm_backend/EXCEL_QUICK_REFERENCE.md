# Excel Upload Quick Reference Guide

## 🚀 **Quick Start**

This guide provides a quick reference for all Excel upload structures in the CRM system.

---

## 📋 **Campaign Leads Upload**

### **Required Columns**
```
first_name, last_name, email
```

### **Optional Columns**
```
phone, alt_phone, address_line, city, state, country, zip
```

### **Sample Row**
```csv
John,Doe,john.doe@example.com,+91 9876543210,+91 8765432109,123 Main Street,Mumbai,Maharashtra,India,400001
```

### **Validation**
- ✅ **Required**: first_name, last_name, email
- ✅ **Email Format**: Must be valid email
- ✅ **Duplicates**: Automatically filtered
- ✅ **Distribution**: Randomly assigned to callers

---

## 🏛️ **Prasadam Upload**

### **Required Columns**
```
Name, Date
```

### **Optional Columns**
```
Status, Images, Email
```

### **Sample Row**
```csv
John Doe,21-05-2025,Verified,Sent,Yes
```

### **Validation**
- ✅ **Required**: Name, Date
- ✅ **Date Format**: DD-MM-YYYY
- ✅ **Status Values**: Verified, Not Verified
- ✅ **Images Values**: Sent, Not Sent
- ✅ **Email Values**: Yes, No

---

## 💰 **Donor Upload**

### **Required Columns**
```
Name, Date
```

### **Optional Columns**
```
Status, Images
```

### **Sample Row**
```csv
John Doe,15-01-2024,Verified,Sent
```

### **Validation**
- ✅ **Required**: Name, Date
- ✅ **Date Format**: DD-MM-YYYY
- ✅ **Status Values**: Verified, Not Verified
- ✅ **Images Values**: Sent, Not Sent

---

## 🚫 **Filter Users Upload**

### **Required Columns**
```
Name, Email
```

### **Optional Columns**
```
Phone, Date
```

### **Sample Row**
```csv
John Doe,john.doe@example.com,+91 9876543210,2024-01-15
```

### **Validation**
- ✅ **Required**: Name, Email
- ✅ **Email Format**: Must be valid email
- ✅ **Date Format**: YYYY-MM-DD
- ✅ **Phone Format**: Optional

---

## 📄 **File Requirements**

### **Supported Formats**
- ✅ **Excel**: .xlsx, .xls
- ✅ **CSV**: .csv
- ❌ **Other**: Not supported

### **File Limits**
- 📏 **Size**: Maximum 10MB
- 📊 **Rows**: No practical limit
- 📋 **Columns**: As specified above

### **Encoding**
- ✅ **UTF-8**: Recommended
- ✅ **Other**: May work but not guaranteed

---

## ⚠️ **Common Errors & Solutions**

| Error | Cause | Solution |
|-------|-------|----------|
| **Missing Required Columns** | Column names don't match | Check exact column names |
| **Invalid Date Format** | Wrong date format | Use DD-MM-YYYY for Prasadam/Donor, YYYY-MM-DD for Filter |
| **Invalid Email** | Bad email format | Use valid email format |
| **File Too Large** | Over 10MB | Split into smaller files |
| **Empty File** | No data in file | Add data to Excel |
| **Duplicate Data** | Existing records | System filters automatically |

---

## 🔧 **Quick Tips**

### **Before Upload**
1. ✅ Check column names exactly
2. ✅ Fill required fields
3. ✅ Use correct date formats
4. ✅ Validate email addresses
5. ✅ Remove duplicates manually

### **During Upload**
1. ✅ Preview parsed data
2. ✅ Check for validation errors
3. ✅ Monitor upload progress
4. ✅ Note any skipped rows

### **After Upload**
1. ✅ Verify data in system
2. ✅ Check for error messages
3. ✅ Save upload confirmation
4. ✅ Keep original file as backup

---

## 📞 **Need Help?**

### **Check These First**
- 📋 Column names match exactly
- 📅 Date format is correct
- 📧 Email format is valid
- 📏 File size under 10MB
- 📄 File format is supported

### **Still Having Issues?**
- 📖 Read full documentation: `EXCEL_UPLOAD_STRUCTURES.md`
- 🧪 Run test script: `node test_excel_structures.js`
- 📞 Contact technical support

---

## 🎯 **Quick Templates**

### **Campaign Leads Template**
```csv
first_name,last_name,email,phone,alt_phone,address_line,city,state,country,zip
John,Doe,john.doe@example.com,+91 9876543210,+91 8765432109,123 Main Street,Mumbai,Maharashtra,India,400001
```

### **Prasadam Template**
```csv
Name,Date,Status,Images,Email
John Doe,21-05-2025,Verified,Sent,Yes
```

### **Donor Template**
```csv
Name,Date,Status,Images
John Doe,15-01-2024,Verified,Sent
```

### **Filter Users Template**
```csv
Name,Email,Phone,Date
John Doe,john.doe@example.com,+91 9876543210,2024-01-15
```

---

*Quick Reference Guide v1.0*
*Last Updated: January 2025*
