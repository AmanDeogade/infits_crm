const db = require('./db');

console.log('🔍 Checking Users Table Structure...\n');

const checkUsersTable = async () => {
    try {
        // Check users table structure
        console.log('1. Checking users table structure...');
        const [columns] = await db.query("DESCRIBE users");
        console.log('Users table columns:');
        columns.forEach(col => {
            console.log(`  - ${col.Field}: ${col.Type} ${col.Null === 'NO' ? 'NOT NULL' : 'NULL'}`);
        });
        
        // Check sample user data
        console.log('\n2. Sample user data:');
        const [users] = await db.query("SELECT * FROM users LIMIT 3");
        users.forEach((user, index) => {
            console.log(`  User ${index + 1}:`, user);
        });
        
        // Check leads table structure
        console.log('\n3. Checking leads table structure...');
        const [leadColumns] = await db.query("DESCRIBE leads");
        console.log('Leads table columns:');
        leadColumns.forEach(col => {
            console.log(`  - ${col.Field}: ${col.Type} ${col.Null === 'NO' ? 'NOT NULL' : 'NULL'}`);
        });
        
        // Check lead status values
        console.log('\n4. Checking lead status values...');
        const [statuses] = await db.query("SELECT DISTINCT current_status FROM leads");
        console.log('Available lead statuses:');
        statuses.forEach(status => {
            console.log(`  - ${status.current_status}`);
        });
        
    } catch (error) {
        console.error('❌ Check failed:', error.message);
    } finally {
        process.exit(0);
    }
};

checkUsersTable();
