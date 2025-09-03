const db = require('../db');
const campaignAssigneeModel = require('../models/campaign_assignee');
const userModel = require('../models/user');

exports.assignUserToCampaign = async (req, res) => {
    try {
        const { campaign_id, user_id, role_in_campaign = 'caller' } = req.body;
        const assigned_by = req.user?.id; // From authentication middleware

        if (!campaign_id || !user_id) {
            return res.status(400).json({ error: 'Campaign ID and User ID are required' });
        }

        // Check if campaign exists
        const [campaigns] = await db.query('SELECT * FROM campaigns WHERE id = ?', [campaign_id]);
        if (campaigns.length === 0) {
            return res.status(404).json({ error: 'Campaign not found' });
        }

        // Check if user exists
        const [users] = await db.query('SELECT * FROM users WHERE id = ?', [user_id]);
        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Check if assignment already exists
        const existingAssignment = await campaignAssigneeModel.findByCampaignAndUser(campaign_id, user_id);
        if (existingAssignment) {
            return res.status(400).json({ error: 'User is already assigned to this campaign' });
        }

        const assignmentId = await campaignAssigneeModel.create({
            campaign_id,
            user_id,
            assigned_by,
            role_in_campaign
        });

        const [assignments] = await db.query(`
            SELECT ca.*, u.name as user_name, u.email as user_email, u.initials as user_initials
            FROM campaign_assignees ca
            JOIN users u ON ca.user_id = u.id
            WHERE ca.id = ?
        `, [assignmentId]);

        res.status(201).json({ 
            success: true, 
            assignment: assignments[0] 
        });
    } catch (err) {
        console.error('Assign user to campaign error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
};

exports.getCampaignAssignees = async (req, res) => {
    try {
        const { campaign_id } = req.params;
        
        if (!campaign_id) {
            return res.status(400).json({ error: 'Campaign ID is required' });
        }

        // Check if campaign exists
        const [campaigns] = await db.query('SELECT * FROM campaigns WHERE id = ?', [campaign_id]);
        if (campaigns.length === 0) {
            return res.status(404).json({ error: 'Campaign not found' });
        }

        const assignees = await campaignAssigneeModel.findByCampaignId(campaign_id);
        
        res.json({ 
            success: true, 
            campaign: campaigns[0],
            assignees 
        });
    } catch (err) {
        console.error('Get campaign assignees error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getUserCampaigns = async (req, res) => {
    try {
        const { user_id } = req.params;
        
        if (!user_id) {
            return res.status(400).json({ error: 'User ID is required' });
        }

        // Check if user exists
        const [users] = await db.query('SELECT * FROM users WHERE id = ?', [user_id]);
        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const campaigns = await campaignAssigneeModel.findByUserId(user_id);
        
        res.json({ 
            success: true, 
            user: users[0],
            campaigns 
        });
    } catch (err) {
        console.error('Get user campaigns error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.updateAssignment = async (req, res) => {
    try {
        const { assignment_id } = req.params;
        const { role_in_campaign, is_active } = req.body;

        if (!assignment_id) {
            return res.status(400).json({ error: 'Assignment ID is required' });
        }

        // Check if assignment exists
        const [assignments] = await db.query('SELECT * FROM campaign_assignees WHERE id = ?', [assignment_id]);
        if (assignments.length === 0) {
            return res.status(404).json({ error: 'Assignment not found' });
        }

        await campaignAssigneeModel.update(assignment_id, {
            role_in_campaign,
            is_active
        });

        const [updatedAssignments] = await db.query(`
            SELECT ca.*, u.name as user_name, u.email as user_email, u.initials as user_initials
            FROM campaign_assignees ca
            JOIN users u ON ca.user_id = u.id
            WHERE ca.id = ?
        `, [assignment_id]);

        res.json({ 
            success: true, 
            assignment: updatedAssignments[0] 
        });
    } catch (err) {
        console.error('Update assignment error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.removeUserFromCampaign = async (req, res) => {
    try {
        const { campaign_id, user_id } = req.params;

        if (!campaign_id || !user_id) {
            return res.status(400).json({ error: 'Campaign ID and User ID are required' });
        }

        // Check if assignment exists
        const existingAssignment = await campaignAssigneeModel.findByCampaignAndUser(campaign_id, user_id);
        if (!existingAssignment) {
            return res.status(404).json({ error: 'Assignment not found' });
        }

        await campaignAssigneeModel.remove(campaign_id, user_id);

        res.json({ 
            success: true, 
            message: 'User removed from campaign successfully' 
        });
    } catch (err) {
        console.error('Remove user from campaign error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.deleteAssignment = async (req, res) => {
    try {
        const { assignment_id } = req.params;

        if (!assignment_id) {
            return res.status(400).json({ error: 'Assignment ID is required' });
        }

        // Check if assignment exists
        const [assignments] = await db.query('SELECT * FROM campaign_assignees WHERE id = ?', [assignment_id]);
        if (assignments.length === 0) {
            return res.status(404).json({ error: 'Assignment not found' });
        }

        await campaignAssigneeModel.delete(assignment_id);

        res.json({ 
            success: true, 
            message: 'Assignment deleted successfully' 
        });
    } catch (err) {
        console.error('Delete assignment error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
}; 