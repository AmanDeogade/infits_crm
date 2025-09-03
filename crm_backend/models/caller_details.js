const db = require('../db');

exports.create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO caller_details (
            caller_id, tasks_late, tasks_pending, tasks_done, tasks_created,
            whatsapp_incoming, whatsapp_outgoing,
            stage_fresh, stage_interested, stage_committed, stage_not_interested, stage_not_connected, stage_callback, stage_temple_visit, stage_temple_donor, stage_lost, stage_won
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            data.caller_id,
            data.tasks_late || 0,
            data.tasks_pending || 0,
            data.tasks_done || 0,
            data.tasks_created || 0,
            data.whatsapp_incoming || 0,
            data.whatsapp_outgoing || 0,
            data.stage_fresh || 0,
            data.stage_interested || 0,
            data.stage_committed || 0,
            data.stage_not_interested || 0,
            data.stage_not_connected || 0,
            data.stage_callback || 0,
            data.stage_temple_visit || 0,
            data.stage_temple_donor || 0,
            data.stage_lost || 0,
            data.stage_won || 0
        ]
    );
    return result.insertId;
};

exports.findAll = async () => {
    const [rows] = await db.query('SELECT * FROM caller_details');
    return rows;
};

exports.findById = async (id) => {
    const [rows] = await db.query('SELECT * FROM caller_details WHERE id = ?', [id]);
    return rows[0] || null;
};

exports.findByCallerId = async (caller_id) => {
    const [rows] = await db.query('SELECT * FROM caller_details WHERE caller_id = ?', [caller_id]);
    return rows;
};

exports.update = async (id, data) => {
    const fields = [];
    const values = [];
    const columns = [
        'tasks_late', 'tasks_pending', 'tasks_done', 'tasks_created',
        'whatsapp_incoming', 'whatsapp_outgoing',
        'stage_fresh', 'stage_interested', 'stage_committed', 'stage_not_interested', 'stage_not_connected', 'stage_callback', 'stage_temple_visit', 'stage_temple_donor', 'stage_lost', 'stage_won'
    ];
    columns.forEach(col => {
        if (data[col] !== undefined) {
            fields.push(`${col} = ?`);
            values.push(data[col]);
        }
    });
    if (fields.length === 0) return;
    values.push(id);
    await db.query(`UPDATE caller_details SET ${fields.join(', ')} WHERE id = ?`, values);
};

exports.delete = async (id) => {
    await db.query('DELETE FROM caller_details WHERE id = ?', [id]);
}; 