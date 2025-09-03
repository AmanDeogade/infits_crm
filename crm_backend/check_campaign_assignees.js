const db = require('./db');

console.log('🔍 Checking campaign_assignees table...\n');

const checkTable = async () => {
    try {
        // Check table structure
        console.log('1. Table Structure:');
        const [structure] = await db.query('DESCRIBE campaign_assignees');
        console.table(structure);
        
        // Check sample data
        console.log('\n2. Sample Data:');
        const [data] = await db.query('SELECT * FROM campaign_assignees LIMIT 5');
        console.table(data);
        
        // Check total count
        console.log('\n3. Total Records:');
        const [count] = await db.query('SELECT COUNT(*) as total FROM campaign_assignees');
        console.log(`Total campaign_assignees: ${count[0].total}`);
        
        // Check active assignees
        console.log('\n4. Active Assignees:');
        const [active] = await db.query('SELECT COUNT(*) as active FROM campaign_assignees WHERE is_active = TRUE');
        console.log(`Active assignees: ${active[0].active}`);
        
        // Check relationship with users table
        console.log('\n5. Assignee Names (from users table):');
        const [assignees] = await db.query(`
            SELECT 
                ca.id as assignment_id,
                ca.campaign_id,
                ca.user_id,
                u.name as assignee_name,
                u.role as assignee_role,
                ca.is_active
            FROM campaign_assignees ca
            JOIN users u ON ca.user_id = u.id
            WHERE ca.is_active = TRUE
            LIMIT 10
        `);
        console.table(assignees);
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        process.exit(0);
    }
};

checkTable();
