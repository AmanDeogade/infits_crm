const db = require('../db');

exports.create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO leads (first_name, last_name, email, phone, alt_phone, address_line, city, state, country, zip, rating, campaign_id, assigned_to, current_status)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            data.first_name || null,
            data.last_name || null,
            data.email || null,
            data.phone || null,
            data.alt_phone || null,
            data.address_line || null,
            data.city || null,
            data.state || null,
            data.country || null,
            data.zip || null,
            data.rating || null,
            data.campaign_id,
            data.assigned_to || null,
            data.current_status || null
        ]
    );
    return result.insertId;
};

exports.findAll = async () => {
    const [leads] = await db.query('SELECT * FROM leads');
    return leads;
};

exports.findById = async (id) => {
    const [leads] = await db.query('SELECT * FROM leads WHERE id = ?', [id]);
    return leads[0] || null;
};

exports.update = async (id, data) => {
    const fields = [];
    const values = [];
    if (data.first_name !== undefined) { fields.push('first_name = ?'); values.push(data.first_name); }
    if (data.last_name !== undefined) { fields.push('last_name = ?'); values.push(data.last_name); }
    if (data.email !== undefined) { fields.push('email = ?'); values.push(data.email); }
    if (data.phone !== undefined) { fields.push('phone = ?'); values.push(data.phone); }
    if (data.alt_phone !== undefined) { fields.push('alt_phone = ?'); values.push(data.alt_phone); }
    if (data.address_line !== undefined) { fields.push('address_line = ?'); values.push(data.address_line); }
    if (data.city !== undefined) { fields.push('city = ?'); values.push(data.city); }
    if (data.state !== undefined) { fields.push('state = ?'); values.push(data.state); }
    if (data.country !== undefined) { fields.push('country = ?'); values.push(data.country); }
    if (data.zip !== undefined) { fields.push('zip = ?'); values.push(data.zip); }
    if (data.rating !== undefined) { fields.push('rating = ?'); values.push(data.rating); }
    if (data.campaign_id !== undefined) { fields.push('campaign_id = ?'); values.push(data.campaign_id); }
    if (data.assigned_to !== undefined) { fields.push('assigned_to = ?'); values.push(data.assigned_to); }
    if (data.current_status !== undefined) { fields.push('current_status = ?'); values.push(data.current_status); }
    if (fields.length === 0) return;
    values.push(id);
    await db.query(`UPDATE leads SET ${fields.join(', ')} WHERE id = ?`, values);
};

exports.delete = async (id) => {
    await db.query('DELETE FROM leads WHERE id = ?', [id]);
};

// Delete all leads for a given campaign_id
exports.deleteByCampaignId = async (campaignId) => {
    await db.query('DELETE FROM leads WHERE campaign_id = ?', [campaignId]);
};

// Find a lead by email
exports.findByEmail = async (email) => {
    const [leads] = await db.query('SELECT * FROM leads WHERE email = ?', [email]);
    return leads[0] || null;
};

// Find a lead by phone
exports.findByPhone = async (phone) => {
    const [leads] = await db.query('SELECT * FROM leads WHERE phone = ?', [phone]);
    return leads[0] || null;
};

// Count leads by campaign_id
exports.countByCampaignId = async (campaignId) => {
    const [rows] = await db.query('SELECT COUNT(*) as count FROM leads WHERE campaign_id = ?', [campaignId]);
    return rows[0]?.count || 0;
};

// Find leads by assignee (campaign_assignee_id)
exports.findByAssignee = async (assigneeId) => {
    const [leads] = await db.query('SELECT * FROM leads WHERE assigned_to = ?', [assigneeId]);
    return leads;
};

// Find leads by campaign and assignee
exports.findByCampaignAndAssignee = async (campaignId, assigneeId) => {
    const [leads] = await db.query('SELECT * FROM leads WHERE campaign_id = ? AND assigned_to = ?', [campaignId, assigneeId]);
    return leads;
};

// Count leads assigned to a specific assignee
exports.countByAssignee = async (assigneeId) => {
    const [rows] = await db.query('SELECT COUNT(*) as count FROM leads WHERE assigned_to = ?', [assigneeId]);
    return rows[0]?.count || 0;
};

// Count unassigned leads in a campaign
exports.countUnassignedByCampaignId = async (campaignId) => {
    const [rows] = await db.query('SELECT COUNT(*) as count FROM leads WHERE campaign_id = ? AND assigned_to IS NULL', [campaignId]);
    return rows[0]?.count || 0;
}; 