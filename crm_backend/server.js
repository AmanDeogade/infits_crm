const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
};

// Modular routes
app.use('/auth', require('./routes/auth'));
app.use('/users', require('./routes/users'));
app.use('/campaigns', require('./routes/campaigns'));
app.use('/leads', require('./routes/leads'));
app.use('/callers', require('./routes/callers'));
app.use('/caller-details', require('./routes/caller_details'));
app.use('/call-metrics', require('./routes/call_metrics'));
app.use('/campaign-assignees', require('./routes/campaign_assignees'));
app.use('/assignee-leads', require('./routes/assignee_leads'));
app.use('/filter-users', require('./routes/filter_users'));
app.use('/assignees', require('./routes/assignees'));
app.use('/donors', require('./controllers/donorController'));
app.use('/prasad', require('./controllers/prasadController'));

// Keep /init-db, /test, and /health endpoints here
app.get('/init-db', async (req, res) => {
    try {
        const [tables] = await db.query('SHOW TABLES LIKE "users"');
        if (tables.length === 0) {
            res.json({ 
                status: 'Tables missing', 
                message: 'Database tables need to be created. Please run the schema.sql file.',
                instructions: [
                    '1. Open MySQL command line or phpMyAdmin',
                    '2. Create database: CREATE DATABASE crm_database;',
                    '3. Import schema.sql file',
                    '4. Or use: mysql -u root -p crm_database < schema.sql'
                ]
            });
        } else {
            res.json({ 
                status: 'OK', 
                message: 'Database tables exist',
                tables: ['users', 'campaigns', 'contacts', 'calling_reports']
            });
        }
    } catch (err) {
        console.error('Database check error:', err);
        res.status(500).json({ 
            error: 'Database error', 
            details: err.message,
            instructions: 'Please check your MySQL setup and run schema.sql'
        });
    }
});

app.get('/test', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'Backend is working!',
        timestamp: new Date().toISOString(),
        endpoints: {
            health: '/health',
            register: '/auth/register',
            login: '/auth/login',
            profile: '/auth/profile'
        }
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: 'Server is running' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
