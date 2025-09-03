const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const userModel = require('../models/user');
const callerModel = require('../models/caller');
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

exports.register = async (req, res) => {
    try {
        const { name, email, password, initials, role, phone, country_code } = req.body;
        if (!name || !email || !password) {
            return res.status(400).json({ error: 'Name, email, and password are required' });
        }
        if (password.length < 6) {
            return res.status(400).json({ error: 'Password must be at least 6 characters long' });
        }
        const existingUser = await userModel.findByEmail(email);
        if (existingUser) {
            return res.status(400).json({ error: 'User with this email already exists' });
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const userId = await userModel.create(name, email, hashedPassword, initials, role, phone, country_code);
        
        // Get the created user to return the actual initials (in case they were auto-generated)
        const createdUser = await userModel.findById(userId);
        
        // If user role is 'caller', add them to the callers table
        if (role === 'caller') {
            try {
                await callerModel.create({
                    name: name,
                    total_calls: 0,
                    connected_calls: 0,
                    not_connected_calls: 0,
                    total_duration_minutes: 0,
                    duration_raise_percentage: 0.0,
                    first_call_time: null,
                    last_call_time: null
                });
                console.log(`Caller record created for user: ${name} (ID: ${userId})`);
            } catch (callerError) {
                console.error('Error creating caller record:', callerError);
                // Don't fail the user creation if caller creation fails
            }
        }
        
        const token = jwt.sign(
            { userId: userId, email: email },
            JWT_SECRET,
            { expiresIn: '24h' }
        );
        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            token: token,
            user: {
                id: userId,
                name: name,
                email: email,
                initials: createdUser.initials,
                role: role || 'caller',
                phone: phone,
                country_code: country_code || '+91'
            }
        });
    } catch (err) {
        console.error('Registration error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }
        const user = await userModel.findByEmail(email);
        if (!user) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }
        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }
        const token = jwt.sign(
            { userId: user.id, email: user.email },
            JWT_SECRET,
            { expiresIn: '24h' }
        );
        res.json({
            success: true,
            message: 'Login successful',
            token: token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                initials: user.initials,
                role: user.role,
                phone: user.phone,
                country_code: user.country_code
            }
        });
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getProfile = async (req, res) => {
    try {
        const user = await userModel.findById(req.user.userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({
            success: true,
            user
        });
    } catch (err) {
        console.error('Profile error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        console.log('Received request body:', req.body);
        const { name, email, initials, role, phone, country_code } = req.body;
        console.log('Destructured values:');
        console.log('  name:', name);
        console.log('  email:', email);
        console.log('  initials:', initials);
        console.log('  role:', role);
        console.log('  phone:', phone);
        console.log('  country_code:', country_code);
        
        if (!name || !email) {
            return res.status(400).json({ error: 'Name and email are required' });
        }
        const existingUsers = await userModel.findByEmailExceptId(email, req.user.userId);
        if (existingUsers.length > 0) {
            return res.status(400).json({ error: 'Email is already taken' });
        }
        // Only pass fields that exist in the request body
        const updateParams = [req.user.userId, name, email];
        
        // Add optional fields in the correct order: [initials, role, phone, country_code]
        // We need to handle missing fields by passing undefined
        const initialsValue = ('initials' in req.body && req.body.initials && req.body.initials !== '') ? req.body.initials : undefined;
        const roleValue = ('role' in req.body && req.body.role && req.body.role !== '') ? req.body.role : undefined;
        const phoneValue = ('phone' in req.body && req.body.phone !== undefined) ? req.body.phone : undefined;
        const countryCodeValue = ('country_code' in req.body && req.body.country_code && req.body.country_code !== '') ? req.body.country_code : undefined;
        
        // Always add all 4 optional parameters in the correct order
        updateParams.push(initialsValue);
        updateParams.push(roleValue);
        updateParams.push(phoneValue);
        updateParams.push(countryCodeValue);
        
        console.log('Calling updateProfile with params:', updateParams);
        console.log('Parameter mapping:');
        console.log('  id:', updateParams[0]);
        console.log('  name:', updateParams[1]);
        console.log('  email:', updateParams[2]);
        if (updateParams.length > 3) console.log('  initials:', updateParams[3]);
        if (updateParams.length > 4) console.log('  role:', updateParams[4]);
        if (updateParams.length > 5) console.log('  phone:', updateParams[5]);
        if (updateParams.length > 6) console.log('  country_code:', updateParams[6]);
        await userModel.updateProfile(...updateParams);
        res.json({
            success: true,
            message: 'Profile updated successfully',
            user: { 
                id: req.user.userId, 
                name, 
                email, 
                initials, 
                role, 
                phone, 
                country_code 
            }
        });
    } catch (err) {
        console.error('Profile update error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.changePassword = async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;
        if (!currentPassword || !newPassword) {
            return res.status(400).json({ error: 'Current password and new password are required' });
        }
        if (newPassword.length < 6) {
            return res.status(400).json({ error: 'New password must be at least 6 characters long' });
        }
        const user = await userModel.findById(req.user.userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        const isValidPassword = await bcrypt.compare(currentPassword, user.password);
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Current password is incorrect' });
        }
        const hashedNewPassword = await bcrypt.hash(newPassword, 10);
        await userModel.updatePassword(req.user.userId, hashedNewPassword);
        res.json({
            success: true,
            message: 'Password changed successfully'
        });
    } catch (err) {
        console.error('Password change error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 