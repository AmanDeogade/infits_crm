const db = require('../db');

exports.create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO campaign_assignees (campaign_id, user_id, assigned_by, role_in_campaign)
         VALUES (?, ?, ?, ?)`,
        [
            data.campaign_id,
            data.user_id,
            data.assigned_by || null,
            data.role_in_campaign || 'caller'
        ]
    );
    return result.insertId;
};

exports.findByCampaignId = async (campaignId) => {
    const [assignees] = await db.query(`
        SELECT ca.*, u.name as user_name, u.email as user_email, u.initials as user_initials, u.role as user_role
        FROM campaign_assignees ca
        JOIN users u ON ca.user_id = u.id
        WHERE ca.campaign_id = ? AND ca.is_active = TRUE
        ORDER BY ca.assigned_at DESC
    `, [campaignId]);
    return assignees;
};

exports.findByUserId = async (userId) => {
    const [campaigns] = await db.query(`
        SELECT c.*, ca.role_in_campaign, ca.assigned_at
        FROM campaigns c
        JOIN campaign_assignees ca ON c.id = ca.campaign_id
        WHERE ca.user_id = ? AND ca.is_active = TRUE
        ORDER BY ca.assigned_at DESC
    `, [userId]);
    return campaigns;
};

exports.findByCampaignAndUser = async (campaignId, userId) => {
    const [assignees] = await db.query(
        'SELECT * FROM campaign_assignees WHERE campaign_id = ? AND user_id = ? AND is_active = TRUE',
        [campaignId, userId]
    );
    return assignees[0] || null;
};

exports.findById = async (id) => {
    const [assignees] = await db.query(`
        SELECT ca.*, u.name as user_name, u.email as user_email, u.initials as user_initials, u.role as user_role
        FROM campaign_assignees ca
        JOIN users u ON ca.user_id = u.id
        WHERE ca.id = ?
    `, [id]);
    return assignees[0] || null;
};

exports.update = async (id, data) => {
    const fields = [];
    const values = [];
    if (data.role_in_campaign !== undefined) { fields.push('role_in_campaign = ?'); values.push(data.role_in_campaign); }
    if (data.is_active !== undefined) { fields.push('is_active = ?'); values.push(data.is_active); }
    if (fields.length === 0) return;
    values.push(id);
    await db.query(`UPDATE campaign_assignees SET ${fields.join(', ')} WHERE id = ?`, values);
};

exports.remove = async (campaignId, userId) => {
    await db.query(
        'UPDATE campaign_assignees SET is_active = FALSE WHERE campaign_id = ? AND user_id = ?',
        [campaignId, userId]
    );
};

exports.delete = async (id) => {
    await db.query('DELETE FROM campaign_assignees WHERE id = ?', [id]);
};

exports.countByCampaignId = async (campaignId) => {
    const [result] = await db.query(
        'SELECT COUNT(*) as count FROM campaign_assignees WHERE campaign_id = ? AND is_active = TRUE',
        [campaignId]
    );
    return result[0].count;
}; 