# Prasadam Excel Upload Template

## 📊 **Required Excel Format**

Your Excel file should have the following columns in the first row:

| Column Name | Required | Description | Example Values |
|-------------|----------|-------------|----------------|
| **Name** | ✅ Yes | Donor's full name | "John Doe", "Jane Smith" |
| **Date** | ✅ Yes | Donation date in DD-MM-YYYY format | "21-05-2025", "15-01-2024" |
| **Status** | ❌ No | Verification status | "Verified", "Not Verified" |
| **Images** | ❌ No | Images sent status | "Sent", "Not Sent" |
| **Email** | ❌ No | Email sent status | "Yes", "No" |

## 📋 **Sample Data**

Here's how your Excel should look:

| Name | Date | Status | Images | Email |
|------|------|--------|--------|-------|
| John Doe | 21-05-2025 | Verified | Sent | Yes |
| Jane Smith | 20-01-2024 | Not Verified | Not Sent | No |
| Mike Johnson | 25-01-2024 | Verified | Sent | Yes |
| Sarah Wilson | 30-01-2024 | Not Verified | Not Sent | No |
| Robert Brown | 01-02-2024 | Verified | Sent | Yes |

## ⚠️ **Important Notes**

1. **Column Names**: Must be exactly as shown above (case-sensitive)
2. **Date Format**: Use DD-MM-YYYY format (e.g., "21-05-2025")
3. **Required Fields**: Only "Name" and "Date" are mandatory
4. **Optional Fields**: Status, Images, and Email will use defaults if empty
   - Status: defaults to "Not Verified"
   - Images: defaults to "Not Sent"
   - Email: defaults to "No"

## 🔧 **Supported File Formats**

- **Excel**: .xlsx, .xls
- **CSV**: .csv
- **File Size**: Maximum 10MB

## 📝 **Example Excel Creation**

1. Open Excel or Google Sheets
2. Create headers in row 1: `Name`, `Date`, `Status`, `Images`, `Email`
3. Add your data starting from row 2
4. Save as .xlsx format
5. Upload using the "Upload Excel" button

## 🚀 **Upload Process**

1. Click "Upload Excel" button
2. Select your Excel file
3. System will validate the format
4. Preview the detected data
5. Click "Next" to upload to database
6. View upload results and any errors

## ❌ **Common Errors to Avoid**

- **Missing Columns**: Ensure "Name" and "Date" columns exist
- **Wrong Date Format**: Use DD-MM-YYYY, not MM/DD/YYYY
- **Empty Required Fields**: Name and Date cannot be empty
- **Invalid Status Values**: Use only "Verified" or "Not Verified"
- **Invalid Images Values**: Use only "Sent" or "Not Sent"
- **Invalid Email Values**: Use only "Yes" or "No"

## 📞 **Need Help?**

If you encounter issues:
1. Check the column names match exactly
2. Verify date format is DD-MM-YYYY
3. Ensure required fields are filled
4. Check file size is under 10MB
5. Try saving as .xlsx format



