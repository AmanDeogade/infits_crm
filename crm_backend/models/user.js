const db = require('../db');

exports.findByEmail = async (email) => {
    const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    return users[0] || null;
};

exports.findById = async (id) => {
    const [users] = await db.query('SELECT id, name, email, initials, role, permission_template_id, reporting_to, phone, country_code, created_at FROM users WHERE id = ?', [id]);
    return users[0] || null;
};

exports.create = async (name, email, hashedPassword, initials = null, role = 'caller', phone = null, country_code = '+91') => {
    // Generate initials from name if not provided
    let userInitials = initials;
    if (!userInitials || userInitials.trim() === '') {
        const nameParts = name.trim().split(' ');
        if (nameParts.length >= 2) {
            userInitials = (nameParts[0][0] + nameParts[nameParts.length - 1][0]).toUpperCase();
        } else {
            userInitials = nameParts[0].substring(0, 2).toUpperCase();
        }
    }
    
    const [result] = await db.query(
        'INSERT INTO users (name, email, password, initials, role, phone, country_code) VALUES (?, ?, ?, ?, ?, ?, ?)', 
        [name, email, hashedPassword, userInitials, role, phone, country_code]
    );
    return result.insertId;
};

exports.updateProfile = async (id, name, email, ...optionalFields) => {
    const updateFields = [];
    const updateValues = [];
    
    // Always include name and email if they exist
    if (name && name !== undefined && name !== null && name !== '') {
        updateFields.push('name = ?');
        updateValues.push(name);
    }
    if (email && email !== undefined && email !== null && email !== '') {
        updateFields.push('email = ?');
        updateValues.push(email);
    }
    
    // Handle optional fields - we need to determine which field each parameter represents
    // The controller sends them in this order: [initials, role, phone, country_code]
    // But we need to handle cases where some fields are missing
    
    let fieldIndex = 0;
    
    // Check for initials (optionalFields[0])
    if (optionalFields.length > fieldIndex && optionalFields[fieldIndex] !== undefined && optionalFields[fieldIndex] !== null && optionalFields[fieldIndex] !== '') {
        updateFields.push('initials = ?');
        updateValues.push(optionalFields[fieldIndex]);
    }
    fieldIndex++;
    
    // Check for role (optionalFields[1])
    if (optionalFields.length > fieldIndex && optionalFields[fieldIndex] !== undefined && optionalFields[fieldIndex] !== null && optionalFields[fieldIndex] !== '') {
        updateFields.push('role = ?');
        updateValues.push(optionalFields[fieldIndex]);
    }
    fieldIndex++;
    
    // Check for phone (optionalFields[2])
    if (optionalFields.length > fieldIndex && optionalFields[fieldIndex] !== undefined && optionalFields[fieldIndex] !== null) {
        updateFields.push('phone = ?');
        updateValues.push(optionalFields[fieldIndex]);
    }
    fieldIndex++;
    
    // Check for country_code (optionalFields[3])
    if (optionalFields.length > fieldIndex && optionalFields[fieldIndex] !== undefined && optionalFields[fieldIndex] !== null && optionalFields[fieldIndex] !== '') {
        updateFields.push('country_code = ?');
        updateValues.push(optionalFields[fieldIndex]);
    }
    
    if (updateFields.length === 0) {
        throw new Error('No valid fields to update');
    }
    
    updateValues.push(id);
    
    console.log('Update query:', `UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`);
    console.log('Update values:', updateValues);
    
    await db.query(`UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`, updateValues);
};

exports.updatePassword = async (id, hashedPassword) => {
    await db.query('UPDATE users SET password = ? WHERE id = ?', [hashedPassword, id]);
};

exports.findAll = async () => {
    const [rows] = await db.query('SELECT id, name, email, initials, role, permission_template_id, reporting_to, phone, country_code, created_at FROM users');
    return rows;
};

exports.findByEmailExceptId = async (email, id) => {
    const [users] = await db.query('SELECT * FROM users WHERE email = ? AND id != ?', [email, id]);
    return users;
};

exports.findByRole = async (role) => {
    const [users] = await db.query('SELECT id, name, email, initials, role, phone, country_code, created_at FROM users WHERE role = ?', [role]);
    return users;
};

exports.findByReportingTo = async (reportingTo) => {
    const [users] = await db.query('SELECT id, name, email, initials, role, phone, country_code, created_at FROM users WHERE reporting_to = ?', [reportingTo]);
    return users;
};

exports.updateRole = async (id, role) => {
    await db.query('UPDATE users SET role = ? WHERE id = ?', [role, id]);
};

exports.updateReportingTo = async (id, reportingTo) => {
    await db.query('UPDATE users SET reporting_to = ? WHERE id = ?', [reportingTo, id]);
};

exports.update = async (id, userData) => {
    const { name, email, phone, initials, role, country_code, reporting_to } = userData;
    
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
    if (initials !== undefined) {
        updateFields.push('initials = ?');
        updateValues.push(initials);
    }
    if (role !== undefined) {
        updateFields.push('role = ?');
        updateValues.push(role);
    }
    if (country_code !== undefined) {
        updateFields.push('country_code = ?');
        updateValues.push(country_code);
    }
    if (reporting_to !== undefined) {
        updateFields.push('reporting_to = ?');
        updateValues.push(reporting_to);
    }
    
    if (updateFields.length === 0) {
        throw new Error('No fields to update');
    }
    
    updateValues.push(id);
    await db.query(`UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`, updateValues);
};

exports.delete = async (id) => {
    await db.query('DELETE FROM users WHERE id = ?', [id]);
}; 