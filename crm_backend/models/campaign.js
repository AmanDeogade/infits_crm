const db = require('../db');

exports.create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO campaigns (name, description, created_by, start_date, end_date, progress_pct, status, total_leads)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            data.name,
            data.description || null,
            data.created_by,
            data.start_date || null,
            data.end_date || null,
            data.progress_pct || 0.0,
            data.status || 'DRAFT',
            data.total_leads || 0
        ]
    );
    return result.insertId;
};

exports.findAll = async () => {
    const [campaigns] = await db.query('SELECT * FROM campaigns');
    return campaigns;
};

exports.findById = async (id) => {
    const [campaigns] = await db.query('SELECT * FROM campaigns WHERE id = ?', [id]);
    return campaigns[0] || null;
};

exports.update = async (id, data) => {
    const fields = [];
    const values = [];
    if (data.name !== undefined) { fields.push('name = ?'); values.push(data.name); }
    if (data.description !== undefined) { fields.push('description = ?'); values.push(data.description); }
    if (data.start_date !== undefined) { fields.push('start_date = ?'); values.push(data.start_date); }
    if (data.end_date !== undefined) { fields.push('end_date = ?'); values.push(data.end_date); }
    if (data.progress_pct !== undefined) { fields.push('progress_pct = ?'); values.push(data.progress_pct); }
    if (data.status !== undefined) { fields.push('status = ?'); values.push(data.status); }
    if (data.total_leads !== undefined) { fields.push('total_leads = ?'); values.push(data.total_leads); }
    if (fields.length === 0) return;
    values.push(id);
    await db.query(`UPDATE campaigns SET ${fields.join(', ')} WHERE id = ?`, values);
};

exports.delete = async (id) => {
    await db.query('DELETE FROM campaigns WHERE id = ?', [id]);
}; 