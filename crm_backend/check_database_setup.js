const db = require('./db');

console.log('🔍 Checking Database Setup...\n');

const checkDatabaseSetup = async () => {
    try {
        // Check if assignee_leads table exists
        console.log('1. Checking if assignee_leads table exists...');
        const [tables] = await db.query("SHOW TABLES LIKE 'assignee_leads'");
        
        if (tables.length > 0) {
            console.log('✅ assignee_leads table exists');
            
            // Check table structure
            console.log('\n2. Checking table structure...');
            const [columns] = await db.query("DESCRIBE assignee_leads");
            console.log('Table columns:');
            columns.forEach(col => {
                console.log(`  - ${col.Field}: ${col.Type} ${col.Null === 'NO' ? 'NOT NULL' : 'NULL'}`);
            });
            
            // Check if table has data
            console.log('\n3. Checking if table has data...');
            const [count] = await db.query("SELECT COUNT(*) as count FROM assignee_leads");
            console.log(`Records in table: ${count[0].count}`);
            
            if (count[0].count > 0) {
                console.log('\n4. Sample data:');
                const [sample] = await db.query("SELECT * FROM assignee_leads LIMIT 3");
                sample.forEach((row, index) => {
                    console.log(`  Record ${index + 1}:`, row);
                });
            }
            
        } else {
            console.log('❌ assignee_leads table does NOT exist');
            console.log('\n💡 You need to run the SQL scripts first:');
            console.log('1. mysql -u root -p < create_assignee_leads_table.sql');
            console.log('2. mysql -u root -p < equal_lead_distribution.sql');
        }
        
        // Check related tables
        console.log('\n5. Checking related tables...');
        const [campaigns] = await db.query("SELECT COUNT(*) as count FROM campaigns");
        const [leads] = await db.query("SELECT COUNT(*) as count FROM leads");
        const [users] = await db.query("SELECT COUNT(*) as count FROM users WHERE role IN ('caller', 'manager', 'supervisor')");
        
        console.log(`  - Campaigns: ${campaigns[0].count}`);
        console.log(`  - Leads: ${leads[0].count}`);
        console.log(`  - Assignees (caller/manager/supervisor): ${users[0].count}`);
        
    } catch (error) {
        console.error('❌ Database check failed:', error.message);
        console.log('\n💡 This might mean:');
        console.log('1. Database connection failed');
        console.log('2. Database credentials are incorrect');
        console.log('3. Database server is not running');
    } finally {
        process.exit(0);
    }
};

checkDatabaseSetup();
