const userModel = require('../models/user');
const callerModel = require('../models/caller');

// Helper function to manage caller records
const manageCallerRecord = async (user, action) => {
    try {
        if (action === 'create') {
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
            console.log(`Caller record created for user: ${user.name}`);
        } else if (action === 'delete') {
            const callers = await callerModel.findAll();
            const callerRecord = callers.find(caller => caller.name === user.name);
            if (callerRecord) {
                await callerModel.delete(callerRecord.id);
                console.log(`Caller record deleted for user: ${user.name}`);
            }
        }
    } catch (error) {
        console.error(`Error ${action}ing caller record for user ${user.name}:`, error);
        // Don't throw error to avoid breaking the main operation
    }
};

// Sync existing users with callers table
exports.syncCallersTable = async (req, res) => {
    try {
        const allUsers = await userModel.findAll();
        const existingCallers = await callerModel.findAll();
        
        let created = 0;
        let deleted = 0;
        
        // Add missing callers
        for (const user of allUsers) {
            if (user.role === 'caller') {
                const existingCaller = existingCallers.find(caller => caller.name === user.name);
                if (!existingCaller) {
                    await manageCallerRecord(user, 'create');
                    created++;
                }
            }
        }
        
        // Remove callers that are no longer users or no longer have caller role
        for (const caller of existingCallers) {
            const user = allUsers.find(u => u.name === caller.name);
            if (!user || user.role !== 'caller') {
                await manageCallerRecord({ name: caller.name }, 'delete');
                deleted++;
            }
        }
        
        res.json({ 
            success: true, 
            message: 'Callers table synced successfully',
            created,
            deleted
        });
    } catch (err) {
        console.error('Sync callers table error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getAllUsers = async (req, res) => {
    try {
        const users = await userModel.findAll();
        res.json({ success: true, users });
    } catch (err) {
        console.error('Get users error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getAdminUsers = async (req, res) => {
    try {
        const adminUsers = await userModel.findByRole('admin');
        res.json({ success: true, users: adminUsers });
    } catch (err) {
        console.error('Get admin users error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getUserById = async (req, res) => {
    try {
        const user = await userModel.findById(req.params.id);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ success: true, user });
    } catch (err) {
        console.error('Get user error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getUsersByRole = async (req, res) => {
    try {
        const { role } = req.params;
        const users = await userModel.findByRole(role);
        res.json({ success: true, users });
    } catch (err) {
        console.error('Get users by role error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getUsersByReportingTo = async (req, res) => {
    try {
        const { reportingTo } = req.params;
        const users = await userModel.findByReportingTo(reportingTo);
        res.json({ success: true, users });
    } catch (err) {
        console.error('Get users by reporting to error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateUserRole = async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;
        
        if (!role || !['admin', 'caller', 'marketing', 'manager'].includes(role)) {
            return res.status(400).json({ error: 'Valid role is required' });
        }
        
        // Get current user to check previous role
        const currentUser = await userModel.findById(id);
        if (!currentUser) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        const previousRole = currentUser.role;
        
        // Update user role
        await userModel.updateRole(id, role);
        
        // Handle caller table management
        if (role === 'caller' && previousRole !== 'caller') {
            // User is being changed to caller role - add to callers table
            await manageCallerRecord(currentUser, 'create');
        } else if (previousRole === 'caller' && role !== 'caller') {
            // User is being changed from caller role - remove from callers table
            await manageCallerRecord(currentUser, 'delete');
        }
        
        res.json({ success: true, message: 'User role updated successfully' });
    } catch (err) {
        console.error('Update user role error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateUserReportingTo = async (req, res) => {
    try {
        const { id } = req.params;
        const { reportingTo } = req.body;
        
        await userModel.updateReportingTo(id, reportingTo);
        res.json({ success: true, message: 'User reporting relationship updated successfully' });
    } catch (err) {
        console.error('Update user reporting to error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, email, phone, initials, role, country_code, reporting_to } = req.body;
        
        console.log('Update user request:', { id, name, email, phone, initials, role, country_code, reporting_to });
        
        // Validate required fields
        if (!name || !email || !phone || !initials || !role) {
            return res.status(400).json({ error: 'All fields are required' });
        }
        
        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ error: 'Invalid email format' });
        }
        
        // Validate role
        if (!['admin', 'caller', 'marketing', 'manager'].includes(role)) {
            return res.status(400).json({ error: 'Invalid role' });
        }
        
        // Check if email already exists for another user
        const existingUser = await userModel.findByEmail(email);
        console.log('Existing user check:', existingUser);
        
        if (existingUser && existingUser.id != parseInt(id)) {
            return res.status(400).json({ error: 'Email already exists' });
        }
        
        // Get current user to check previous role
        const currentUser = await userModel.findById(id);
        if (!currentUser) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        const previousRole = currentUser.role;
        
        // Update user
        await userModel.update(parseInt(id), {
            name,
            email,
            phone,
            initials,
            role,
            country_code,
            reporting_to
        });
        
        // Handle caller table management if role changed
        if (role !== previousRole) {
            if (role === 'caller' && previousRole !== 'caller') {
                // User is being changed to caller role - add to callers table
                await manageCallerRecord({ name: name }, 'create');
            } else if (previousRole === 'caller' && role !== 'caller') {
                // User is being changed from caller role - remove from callers table
                await manageCallerRecord(currentUser, 'delete');
            }
        }
        
        console.log('User updated successfully');
        res.json({ success: true, message: 'User updated successfully' });
    } catch (err) {
        console.error('Update user error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.deleteUser = async (req, res) => {
    try {
        const { id } = req.params;
        
        // Check if user exists
        const user = await userModel.findById(id);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        // Check if user has subordinates (users reporting to them)
        const subordinates = await userModel.findByReportingTo(id);
        if (subordinates.length > 0) {
            return res.status(400).json({ 
                error: 'Cannot delete user. This user has subordinates reporting to them. Please reassign or delete the subordinates first.' 
            });
        }
        
        // If user is a caller, remove from callers table
        if (user.role === 'caller') {
            await manageCallerRecord(user, 'delete');
        }
        
        // Delete user
        await userModel.delete(id);
        
        res.json({ success: true, message: 'User deleted successfully' });
    } catch (err) {
        console.error('Delete user error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 