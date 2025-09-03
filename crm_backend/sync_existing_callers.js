const db = require('./db');
const callerModel = require('./models/caller');
const userModel = require('./models/user');

async function syncExistingCallers() {
    try {
        console.log('Starting caller sync...');
        
        // Get all users
        const allUsers = await userModel.findAll();
        console.log(`Found ${allUsers.length} total users`);
        
        // Get existing callers
        const existingCallers = await callerModel.findAll();
        console.log(`Found ${existingCallers.length} existing callers`);
        
        let created = 0;
        let deleted = 0;
        
        // Add missing callers
        for (const user of allUsers) {
            if (user.role === 'caller') {
                const existingCaller = existingCallers.find(caller => caller.name === user.name);
                if (!existingCaller) {
                    try {
                        await callerModel.create({
                            name: user.name,
                            total_calls: 0,
                            connected_calls: 0,
                            not_connected_calls: 0,
                            total_duration_minutes: 0,
                            duration_raise_percentage: 0.0,
                            first_call_time: null,
                            last_call_time: null
                        });
                        console.log(`✅ Created caller record for: ${user.name}`);
                        created++;
                    } catch (error) {
                        console.error(`❌ Error creating caller for ${user.name}:`, error.message);
                    }
                } else {
                    console.log(`ℹ️  Caller already exists for: ${user.name}`);
                }
            }
        }
        
        // Remove callers that are no longer users or no longer have caller role
        for (const caller of existingCallers) {
            const user = allUsers.find(u => u.name === caller.name);
            if (!user || user.role !== 'caller') {
                try {
                    await callerModel.delete(caller.id);
                    console.log(`🗑️  Deleted caller record for: ${caller.name}`);
                    deleted++;
                } catch (error) {
                    console.error(`❌ Error deleting caller ${caller.name}:`, error.message);
                }
            }
        }
        
        console.log('\n=== SYNC SUMMARY ===');
        console.log(`Created: ${created} caller records`);
        console.log(`Deleted: ${deleted} caller records`);
        
        // Show final state
        const finalCallers = await callerModel.findAll();
        console.log(`\nFinal callers in database: ${finalCallers.length}`);
        for (const caller of finalCallers) {
            console.log(`- ${caller.name} (ID: ${caller.id})`);
        }
        
    } catch (error) {
        console.error('Sync error:', error);
    } finally {
        process.exit(0);
    }
}

// Run the sync
syncExistingCallers(); 