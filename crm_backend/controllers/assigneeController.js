const AssigneeLead = require('../models/assignee_lead');
const db = require('../db'); // Added this import for the new method

// Get assignee lead statistics by stage for dashboard
exports.getAssigneeLeadStats = async (req, res) => {
    try {
        // Get all assignees with their lead counts by status
        const rows = await AssigneeLead.getAssigneeLeadStatsByStage();
        
        console.log('Controller received rows:', rows);
        console.log('Rows type:', typeof rows);
        console.log('Rows length:', rows ? rows.length : 'undefined');
        
        res.json({ 
            success: true, 
            assignees: rows 
        });
    } catch (err) {
        console.error('Get assignee lead stats error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// Get lead statistics for a specific assignee
exports.getAssigneeStats = async (req, res) => {
    try {
        const { assigneeId } = req.params;
        const stats = await AssigneeLead.getAssigneeStats(assigneeId);
        
        res.json({ 
            success: true, 
            stats 
        });
    } catch (err) {
        console.error('Get assignee stats error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getFollowUpStats = async (req, res) => {
    try {
        const [results] = await db.query(`
            SELECT 
                u.name as assignee_name,
                COUNT(CASE WHEN al.status = 'Fresh' THEN 1 END) as fresh_count,
                COUNT(CASE WHEN al.status = 'Not Connected' THEN 1 END) as not_connected_count,
                COUNT(CASE WHEN al.status = 'Interested' THEN 1 END) as interested_count,
                COUNT(CASE WHEN al.status = 'Follow Up' THEN 1 END) as follow_up_count,
                COUNT(CASE WHEN al.status = 'Converted' THEN 1 END) as converted_count,
                COUNT(CASE WHEN al.status = 'Rejected' THEN 1 END) as rejected_count,
                COUNT(CASE WHEN al.status = 'Do Not Call' THEN 1 END) as do_not_call_count,
                COUNT(*) as total_leads
            FROM assignee_leads al
            JOIN users u ON al.assignee_id = u.id
            GROUP BY al.assignee_id, u.name
            ORDER BY total_leads DESC
        `);

        res.json({
            success: true,
            follow_ups: results
        });
    } catch (error) {
        console.error('Error fetching follow-up stats:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch follow-up statistics'
        });
    }
};
