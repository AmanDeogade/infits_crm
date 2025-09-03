const db = require('../db');

exports.create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO callers (name, total_calls, connected_calls, not_connected_calls, total_duration_minutes, duration_raise_percentage, first_call_time, last_call_time)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            data.name,
            data.total_calls || 0,
            data.connected_calls || 0,
            data.not_connected_calls || 0,
            data.total_duration_minutes || 0,
            data.duration_raise_percentage || 0.0,
            data.first_call_time || null,
            data.last_call_time || null
        ]
    );
    return result.insertId;
};

exports.findAll = async () => {
    const [callers] = await db.query('SELECT * FROM callers');
    return callers;
};

exports.findById = async (id) => {
    const [callers] = await db.query('SELECT * FROM callers WHERE id = ?', [id]);
    return callers[0] || null;
};

exports.update = async (id, data) => {
    const fields = [];
    const values = [];
    if (data.name !== undefined) { fields.push('name = ?'); values.push(data.name); }
    if (data.total_calls !== undefined) { fields.push('total_calls = ?'); values.push(data.total_calls); }
    if (data.connected_calls !== undefined) { fields.push('connected_calls = ?'); values.push(data.connected_calls); }
    if (data.not_connected_calls !== undefined) { fields.push('not_connected_calls = ?'); values.push(data.not_connected_calls); }
    if (data.total_duration_minutes !== undefined) { fields.push('total_duration_minutes = ?'); values.push(data.total_duration_minutes); }
    if (data.duration_raise_percentage !== undefined) { fields.push('duration_raise_percentage = ?'); values.push(data.duration_raise_percentage); }
    if (data.first_call_time !== undefined) { fields.push('first_call_time = ?'); values.push(data.first_call_time); }
    if (data.last_call_time !== undefined) { fields.push('last_call_time = ?'); values.push(data.last_call_time); }
    if (fields.length === 0) return;
    values.push(id);
    await db.query(`UPDATE callers SET ${fields.join(', ')} WHERE id = ?`, values);
};

exports.delete = async (id) => {
    await db.query('DELETE FROM callers WHERE id = ?', [id]);
}; 