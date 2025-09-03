const db = require('../db');
const leadModel = require('../models/lead');
const campaignAssigneeModel = require('../models/campaign_assignee');

exports.createCampaign = async (req, res) => {
    try {
        const {
            name,
            description,
            start_date,
            end_date,
            progress_pct = 0.0,
            status = 'DRAFT',
            total_leads = 0
        } = req.body;
        if (!name) {
            return res.status(400).json({ error: 'Name is required' });
        }
        
        // Use authenticated user's ID
        const created_by = req.user ? req.user.id : 1;
        
        const [result] = await db.query(
            `INSERT INTO campaigns (name, description, created_by, start_date, end_date, progress_pct, status, total_leads)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                name,
                description || null,
                created_by,
                start_date || null,
                end_date || null,
                progress_pct,
                status,
                total_leads
            ]
        );
        const [campaigns] = await db.query('SELECT * FROM campaigns WHERE id = ?', [result.insertId]);
        res.status(201).json({ success: true, campaign: campaigns[0] });
    } catch (err) {
        console.error('Create campaign error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getAllCampaigns = async (req, res) => {
    try {
        const [campaigns] = await db.query('SELECT * FROM campaigns');
        // For each campaign, fetch the actual total leads and assignees
        for (const campaign of campaigns) {
            campaign.total_leads = await leadModel.countByCampaignId(campaign.id);
            campaign.assignees = await campaignAssigneeModel.findByCampaignId(campaign.id);
            campaign.assignee_count = await campaignAssigneeModel.countByCampaignId(campaign.id);
            campaign.unassigned_leads = await leadModel.countUnassignedByCampaignId(campaign.id);
        }
        res.json({ success: true, campaigns });
    } catch (err) {
        console.error('Get campaigns error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getCampaignById = async (req, res) => {
    try {
        const [campaigns] = await db.query('SELECT * FROM campaigns WHERE id = ?', [req.params.id]);
        if (campaigns.length === 0) {
            return res.status(404).json({ error: 'Campaign not found' });
        }
        
        const campaign = campaigns[0];
        campaign.total_leads = await leadModel.countByCampaignId(campaign.id);
        campaign.assignees = await campaignAssigneeModel.findByCampaignId(campaign.id);
        campaign.assignee_count = await campaignAssigneeModel.countByCampaignId(campaign.id);
        campaign.unassigned_leads = await leadModel.countUnassignedByCampaignId(campaign.id);
        
        res.json({ success: true, campaign });
    } catch (err) {
        console.error('Get campaign error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateCampaign = async (req, res) => {
    try {
        const {
            name,
            description,
            start_date,
            end_date,
            progress_pct,
            status,
            total_leads
        } = req.body;
        const fields = [];
        const values = [];
        if (name !== undefined) { fields.push('name = ?'); values.push(name); }
        if (description !== undefined) { fields.push('description = ?'); values.push(description); }
        if (start_date !== undefined) { fields.push('start_date = ?'); values.push(start_date); }
        if (end_date !== undefined) { fields.push('end_date = ?'); values.push(end_date); }
        if (progress_pct !== undefined) { fields.push('progress_pct = ?'); values.push(progress_pct); }
        if (status !== undefined) { fields.push('status = ?'); values.push(status); }
        if (total_leads !== undefined) { fields.push('total_leads = ?'); values.push(total_leads); }
        if (fields.length === 0) {
            return res.status(400).json({ error: 'No fields to update' });
        }
        values.push(req.params.id);
        await db.query(`UPDATE campaigns SET ${fields.join(', ')} WHERE id = ?`, values);
        const [campaigns] = await db.query('SELECT * FROM campaigns WHERE id = ?', [req.params.id]);
        res.json({ success: true, campaign: campaigns[0] });
    } catch (err) {
        console.error('Update campaign error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.deleteCampaign = async (req, res) => {
    try {
        const [campaigns] = await db.query('SELECT * FROM campaigns WHERE id = ?', [req.params.id]);
        if (campaigns.length === 0) {
            return res.status(404).json({ error: 'Campaign not found' });
        }
        await db.query('DELETE FROM campaigns WHERE id = ?', [req.params.id]);
        res.json({ success: true, message: 'Campaign deleted' });
    } catch (err) {
        console.error('Delete campaign error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 

// Get campaign dashboard statistics
exports.getCampaignDashboardStats = async (req, res) => {
    try {
        // Get all campaigns first
        const [campaigns] = await db.query('SELECT * FROM campaigns ORDER BY created_at DESC');
        
        // For each campaign, get statistics separately to avoid complex joins
        for (const campaign of campaigns) {
            try {
                // Get total leads for this campaign
                const [leadCount] = await db.query(
                    'SELECT COUNT(*) as count FROM leads WHERE campaign_id = ?', 
                    [campaign.id]
                );
                campaign.total_leads = leadCount[0]?.count || 0;
                
                // Get assignee count for this campaign
                const [assigneeCount] = await db.query(
                    'SELECT COUNT(*) as count FROM campaign_assignees WHERE campaign_id = ? AND is_active = TRUE', 
                    [campaign.id]
                );
                campaign.assignee_count = assigneeCount[0]?.count || 0;
                
                // Ensure progress_pct is a number
                campaign.progress_pct = parseFloat(campaign.progress_pct) || 0;
                
            } catch (statError) {
                console.error(`Error getting stats for campaign ${campaign.id}:`, statError);
                // Set default values if there's an error
                campaign.total_leads = 0;
                campaign.assignee_count = 0;
                campaign.progress_pct = 0;
            }
        }
        
        res.json({ success: true, campaigns });
    } catch (err) {
        console.error('Get campaign dashboard stats error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 