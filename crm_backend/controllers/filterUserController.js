const filterUserModel = require('../models/filter_user');

// Get all filter users
exports.getAllFilterUsers = async (req, res) => {
    try {
        const filterUsers = await filterUserModel.findAll();
        res.json({
            success: true,
            data: filterUsers,
            message: 'Filter users retrieved successfully'
        });
    } catch (error) {
        console.error('Error getting filter users:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Get filter user by ID
exports.getFilterUserById = async (req, res) => {
    try {
        const { id } = req.params;
        const filterUser = await filterUserModel.findById(id);
        
        if (!filterUser) {
            return res.status(404).json({
                success: false,
                message: 'Filter user not found'
            });
        }
        
        res.json({
            success: true,
            data: filterUser,
            message: 'Filter user retrieved successfully'
        });
    } catch (error) {
        console.error('Error getting filter user:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Create a new filter user
exports.createFilterUser = async (req, res) => {
    try {
        const { name, email, phone, date } = req.body;
        
        // Validation
        if (!name || !email) {
            return res.status(400).json({
                success: false,
                message: 'Name and email are required fields'
            });
        }
        
        // Email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                message: 'Please provide a valid email address'
            });
        }
        
        // Date validation (optional)
        if (date) {
            const dateObj = new Date(date);
            if (isNaN(dateObj.getTime())) {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide a valid date'
                });
            }
        }
        
        const filterUserId = await filterUserModel.create(name, email, phone, date);
        const newFilterUser = await filterUserModel.findById(filterUserId);
        
        res.status(201).json({
            success: true,
            data: newFilterUser,
            message: 'Filter user created successfully'
        });
    } catch (error) {
        console.error('Error creating filter user:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Update a filter user
exports.updateFilterUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, email, phone, date } = req.body;
        
        // Check if filter user exists
        const existingUser = await filterUserModel.findById(id);
        if (!existingUser) {
            return res.status(404).json({
                success: false,
                message: 'Filter user not found'
            });
        }
        
        // Validation for email if provided
        if (email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide a valid email address'
                });
            }
        }
        
        // Validation for date if provided
        if (date) {
            const dateObj = new Date(date);
            if (isNaN(dateObj.getTime())) {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide a valid date'
                });
            }
        }
        
        const updateData = {};
        if (name !== undefined) updateData.name = name;
        if (email !== undefined) updateData.email = email;
        if (phone !== undefined) updateData.phone = phone;
        if (date !== undefined) updateData.date = date;
        
        const updated = await filterUserModel.update(id, updateData);
        
        if (!updated) {
            return res.status(400).json({
                success: false,
                message: 'No changes made to filter user'
            });
        }
        
        const updatedUser = await filterUserModel.findById(id);
        
        res.json({
            success: true,
            data: updatedUser,
            message: 'Filter user updated successfully'
        });
    } catch (error) {
        console.error('Error updating filter user:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Delete a filter user
exports.deleteFilterUser = async (req, res) => {
    try {
        const { id } = req.params;
        
        // Check if filter user exists
        const existingUser = await filterUserModel.findById(id);
        if (!existingUser) {
            return res.status(404).json({
                success: false,
                message: 'Filter user not found'
            });
        }
        
        const deleted = await filterUserModel.delete(id);
        
        if (!deleted) {
            return res.status(400).json({
                success: false,
                message: 'Failed to delete filter user'
            });
        }
        
        res.json({
            success: true,
            message: 'Filter user deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting filter user:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Search filter users by email
exports.searchByEmail = async (req, res) => {
    try {
        const { email } = req.query;
        
        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email parameter is required'
            });
        }
        
        const filterUsers = await filterUserModel.findByEmail(email);
        
        res.json({
            success: true,
            data: filterUsers,
            message: 'Filter users found successfully'
        });
    } catch (error) {
        console.error('Error searching filter users by email:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Search filter users by date range
exports.searchByDateRange = async (req, res) => {
    try {
        const { startDate, endDate } = req.query;
        
        if (!startDate || !endDate) {
            return res.status(400).json({
                success: false,
                message: 'Start date and end date are required'
            });
        }
        
        const filterUsers = await filterUserModel.findByDateRange(startDate, endDate);
        
        res.json({
            success: true,
            data: filterUsers,
            message: 'Filter users found successfully'
        });
    } catch (error) {
        console.error('Error searching filter users by date range:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Search filter users by name
exports.searchByName = async (req, res) => {
    try {
        const { name } = req.query;
        
        if (!name) {
            return res.status(400).json({
                success: false,
                message: 'Name parameter is required'
            });
        }
        
        const filterUsers = await filterUserModel.findByName(name);
        
        res.json({
            success: true,
            data: filterUsers,
            message: 'Filter users found successfully'
        });
    } catch (error) {
        console.error('Error searching filter users by name:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Bulk create filter users
exports.bulkCreateFilterUsers = async (req, res) => {
    try {
        console.log('Received request body:', req.body);
        const { users } = req.body;
        
        if (!users || !Array.isArray(users) || users.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Users array is required and must not be empty'
            });
        }
        
        // Validate each user
        for (const user of users) {
            if (!user.name || !user.email) {
                return res.status(400).json({
                    success: false,
                    message: 'Each user must have name and email fields'
                });
            }
            
            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(user.email)) {
                return res.status(400).json({
                    success: false,
                    message: `Invalid email format for user: ${user.name}`
                });
            }
            
            // Date validation (optional)
            if (user.date) {
                const dateObj = new Date(user.date);
                if (isNaN(dateObj.getTime())) {
                    return res.status(400).json({
                        success: false,
                        message: `Invalid date format for user: ${user.name}`
                    });
                }
            }
        }
        
        const insertIds = await filterUserModel.bulkCreate(users);
        
        res.status(201).json({
            success: true,
            data: { insertIds },
            message: `${users.length} filter users created successfully`
        });
    } catch (error) {
        console.error('Error bulk creating filter users:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message
        });
    }
}; 