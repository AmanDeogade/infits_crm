const db = require('../db');

exports.create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO call_metrics (
            user_id, total_calls, incoming_calls, outgoing_calls, missed_calls, 
            connected_calls, attempted_calls, total_duration_seconds,
            stage_fresh, stage_interested, stage_committed, stage_not_interested
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            data.user_id,
            data.total_calls || 0,
            data.incoming_calls || 0,
            data.outgoing_calls || 0,
            data.missed_calls || 0,
            data.connected_calls || 0,
            data.attempted_calls || 0,
            data.total_duration_seconds || 0,
            data.stage_fresh || 0,
            data.stage_interested || 0,
            data.stage_committed || 0,
            data.stage_not_interested || 0
        ]
    );
    return result.insertId;
};

exports.findAll = async () => {
    const [rows] = await db.query('SELECT * FROM call_metrics');
    return rows;
};

exports.findById = async (id) => {
    const [rows] = await db.query('SELECT * FROM call_metrics WHERE id = ?', [id]);
    return rows[0] || null;
};

exports.findByUserId = async (user_id) => {
    const [rows] = await db.query('SELECT * FROM call_metrics WHERE user_id = ?', [user_id]);
    return rows;
};

exports.update = async (id, data) => {
    const fields = [];
    const values = [];
    const columns = [
        'total_calls', 'incoming_calls', 'outgoing_calls', 'missed_calls', 
        'connected_calls', 'attempted_calls', 'total_duration_seconds',
        'stage_fresh', 'stage_interested', 'stage_committed', 'stage_not_interested'
    ];
    columns.forEach(col => {
        if (data[col] !== undefined) {
            fields.push(`${col} = ?`);
            values.push(data[col]);
        }
    });
    if (fields.length === 0) return;
    values.push(id);
    await db.query(`UPDATE call_metrics SET ${fields.join(', ')} WHERE id = ?`, values);
};

exports.delete = async (id) => {
    await db.query('DELETE FROM call_metrics WHERE id = ?', [id]);
}; 