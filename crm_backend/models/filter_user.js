const db = require('../db');

// Get all filter users
exports.findAll = async () => {
    const [rows] = await db.query('SELECT * FROM filter_users ORDER BY created_at DESC');
    return rows;
};

// Get filter user by ID
exports.findById = async (id) => {
    const [users] = await db.query('SELECT * FROM filter_users WHERE id = ?', [id]);
    return users[0] || null;
};

// Create a new filter user
exports.create = async (name, email, phone, date = null) => {
    const [result] = await db.query(
        'INSERT INTO filter_users (name, email, phone, date) VALUES (?, ?, ?, ?)', 
        [name, email, phone, date]
    );
    return result.insertId;
};

// Update a filter user
exports.update = async (id, userData) => {
    const { name, email, phone, date } = userData;
    
    const updateFields = [];
    const updateValues = [];
    
    if (name !== undefined) {
        updateFields.push('name = ?');
        updateValues.push(name);
    }
    if (email !== undefined) {
        updateFields.push('email = ?');
        updateValues.push(email);
    }
    if (phone !== undefined) {
        updateFields.push('phone = ?');
        updateValues.push(phone);
    }
    if (date !== undefined) {
        updateFields.push('date = ?');
        updateValues.push(date);
    }
    
    if (updateFields.length === 0) {
        return false;
    }
    
    updateValues.push(id);
    const [result] = await db.query(`UPDATE filter_users SET ${updateFields.join(', ')} WHERE id = ?`, updateValues);
    return result.affectedRows > 0;
};

// Delete a filter user
exports.delete = async (id) => {
    const [result] = await db.query('DELETE FROM filter_users WHERE id = ?', [id]);
    return result.affectedRows > 0;
};

// Find filter users by email
exports.findByEmail = async (email) => {
    const [users] = await db.query('SELECT * FROM filter_users WHERE email = ?', [email]);
    return users;
};

// Find filter users by date range
exports.findByDateRange = async (startDate, endDate) => {
    const [users] = await db.query('SELECT * FROM filter_users WHERE date BETWEEN ? AND ? ORDER BY date', [startDate, endDate]);
    return users;
};

// Find filter users by name (partial match)
exports.findByName = async (name) => {
    const [users] = await db.query('SELECT * FROM filter_users WHERE name LIKE ?', [`%${name}%`]);
    return users;
};

// Bulk create filter users
exports.bulkCreate = async (users) => {
    if (!users || users.length === 0) {
        return [];
    }
    
    const values = users.map(user => [user.name, user.email, user.phone, user.date]);
    const [result] = await db.query(
        'INSERT INTO filter_users (name, email, phone, date) VALUES ?',
        [values]
    );
    
    // Generate insert IDs since MySQL doesn't return them for bulk inserts
    const insertIds = [];
    for (let i = 0; i < users.length; i++) {
        insertIds.push(result.insertId + i);
    }
    
    return insertIds;
}; 