const db = require('../db');

class AssigneeLead {
    // Create a new lead assignment
    static async create(campaignId, assigneeId, leadId, assignedBy, notes = null) {
        try {
            const [result] = await db.query(
                `INSERT INTO assignee_leads (campaign_id, assignee_id, lead_id, assigned_by, status, notes) 
                 VALUES (?, ?, ?, ?, 'Fresh', ?)`,
                [campaignId, assigneeId, leadId, assignedBy, notes]
            );
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    // Get all lead assignments for a specific campaign
    static async getByCampaignId(campaignId) {
        try {
            const [rows] = await db.query(
                `SELECT al.*, 
                        u.name as assignee_name, u.email,
                        l.first_name as lead_first_name, l.last_name as lead_last_name, l.email as lead_email,
                        l.phone as lead_phone, l.current_status as lead_status
                 FROM assignee_leads al
                 JOIN users u ON al.assignee_id = u.id
                 JOIN leads l ON al.lead_id = l.id
                 WHERE al.campaign_id = ? AND al.status != 'Lost'
                 ORDER BY al.assigned_at DESC`,
                [campaignId]
            );
            return rows;
        } catch (error) {
            throw error;
        }
    }

    // Get all lead assignments for a specific assignee
    static async getByAssigneeId(assigneeId) {
        try {
            const [rows] = await db.query(
                `SELECT al.*, 
                        c.name as campaign_name,
                        l.first_name as lead_first_name, l.last_name as lead_last_name, 
                        l.email as lead_email, l.phone as lead_phone, l.current_status as lead_status
                 FROM assignee_leads al
                 JOIN campaigns c ON al.campaign_id = c.id
                 JOIN leads l ON al.lead_id = l.id
                 WHERE al.assignee_id = ? AND al.status != 'Lost'
                 ORDER BY al.assigned_at DESC`,
                [assigneeId]
            );
            return rows;
        } catch (error) {
            throw error;
        }
    }

    // Get lead assignment by lead ID
    static async getByLeadId(leadId) {
        try {
            const [rows] = await db.query(
                `SELECT al.*, 
                        c.name as campaign_name,
                        u.name as assignee_name, u.email
                 FROM assignee_leads al
                 JOIN campaigns c ON al.campaign_id = c.id
                 JOIN users u ON al.assignee_id = u.id
                 WHERE al.lead_id = ? AND al.status != 'Lost'`,
                [leadId]
            );
            return rows[0] || null;
        } catch (error) {
            throw error;
        }
    }

    // Update assignment status
    static async updateStatus(assignmentId, status, notes = null) {
        try {
            // Validate status is one of the allowed enum values
            const allowedStatuses = ['Fresh', 'Not Connected', 'Interested', 'Commited', 'Call Back', 'Not Interested', 'Won', 'Lost', 'Temple Visit', 'Temple Donor'];
            if (!allowedStatuses.includes(status)) {
                throw new Error(`Invalid status. Must be one of: ${allowedStatuses.join(', ')}`);
            }
            
            const [result] = await db.query(
                `UPDATE assignee_leads 
                 SET status = ?, notes = ?, assigned_at = CURRENT_TIMESTAMP
                 WHERE id = ?`,
                [status, notes, assignmentId]
            );
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    // Reassign a lead to a different assignee
    static async reassign(leadId, newAssigneeId, assignedBy, notes = null) {
        try {
            // First, mark the current assignment as reassigned (using 'Lost' status)
            await db.query(
                `UPDATE assignee_leads 
                 SET status = 'Lost', notes = CONCAT(IFNULL(notes, ''), ' - Reassigned to new assignee')
                 WHERE lead_id = ? AND status != 'Lost'`,
                [leadId]
            );

            // Get the campaign ID from the current assignment
            const [currentAssignment] = await db.query(
                `SELECT campaign_id FROM assignee_leads WHERE lead_id = ? ORDER BY assigned_at DESC LIMIT 1`,
                [leadId]
            );

            if (currentAssignment.length > 0) {
                // Create new assignment
                const campaignId = currentAssignment[0].campaign_id;
                return await this.create(campaignId, newAssigneeId, leadId, assignedBy, notes);
            }
            return null;
        } catch (error) {
            throw error;
        }
    }

    // Get assignment statistics for dashboard
    static async getDashboardStats() {
        try {
            const [rows] = await db.query(
                `SELECT 
                    c.id as campaign_id,
                    c.name as campaign_name,
                    COUNT(DISTINCT al.assignee_id) as active_assignees,
                    COUNT(al.lead_id) as assigned_leads,
                    COUNT(CASE WHEN al.status = 'Won' THEN 1 END) as completed_leads,
                    ROUND(COUNT(CASE WHEN al.status = 'Won' THEN 1 END) * 100.0 / COUNT(al.lead_id), 2) as completion_rate
                 FROM campaigns c
                 LEFT JOIN assignee_leads al ON c.id = al.campaign_id AND al.status != 'Lost'
                 GROUP BY c.id, c.name
                 ORDER BY c.created_at DESC`
            );
            return rows;
        } catch (error) {
            throw error;
        }
    }

    // Get assignee performance statistics
    static async getAssigneeStats(assigneeId) {
        try {
            const [rows] = await db.query(
                `SELECT 
                    c.name as campaign_name,
                    COUNT(al.lead_id) as total_assigned,
                    COUNT(CASE WHEN al.status = 'Won' THEN 1 END) as completed,
                    COUNT(CASE WHEN al.status IN ('Fresh', 'Not Connected', 'Interested', 'Commited', 'Call Back', 'Temple Visit', 'Temple Donor') THEN 1 END) as active,
                    ROUND(COUNT(CASE WHEN al.status = 'Won' THEN 1 END) * 100.0 / COUNT(al.lead_id), 2) as success_rate
                 FROM assignee_leads al
                 JOIN campaigns c ON al.campaign_id = c.id
                 WHERE al.assignee_id = ?
                 GROUP BY c.id, c.name
                 ORDER BY c.created_at DESC`,
                [assigneeId]
            );
            return rows;
        } catch (error) {
            throw error;
        }
    }

        // Get assignee lead statistics by stage for dashboard
    static async getAssigneeLeadStatsByStage() {
        try {
            // Direct query using assignee_leads table
            console.log('Using assignee_leads table directly');
            const [rows] = await db.query(
                `SELECT 
                    u.id as assignee_id,
                    u.name as assignee_name,
                    COUNT(CASE WHEN al.status = 'Fresh' THEN 1 END) as fresh_leads,
                    COUNT(CASE WHEN al.status IN ('Not Connected', 'Interested', 'Commited', 'Call Back', 'Temple Visit', 'Temple Donor') THEN 1 END) as active_leads,
                    COUNT(CASE WHEN al.status = 'Won' THEN 1 END) as won_leads,
                    COUNT(CASE WHEN al.status IN ('Not Interested', 'Lost') THEN 1 END) as loss_leads
                 FROM assignee_leads al
                 JOIN users u ON al.assignee_id = u.id
                 WHERE u.role IN ('caller', 'manager', 'supervisor')
                 GROUP BY u.id, u.name
                 ORDER BY u.name`
            );
            return rows;
        } catch (error) {
            throw error;
        }
    }

    // Get all assignee_lead records
    static async getAll() {
        try {
            const [rows] = await db.query(
                `SELECT al.*, 
                        c.name as campaign_name,
                        u.name as assignee_name, u.email,
                        l.first_name as lead_first_name, l.last_name as lead_last_name, 
                        l.email as lead_email, l.phone as lead_phone, l.current_status as lead_status
                 FROM assignee_leads al
                 JOIN campaigns c ON al.campaign_id = c.id
                 JOIN users u ON al.assignee_id = u.id
                 JOIN leads l ON al.lead_id = l.id
                 ORDER BY al.assigned_at DESC`
            );
            return rows;
        } catch (error) {
            throw error;
        }
    }

    // Delete assignment (soft delete by changing status)
    static async delete(assignmentId) {
        try {
            const [result] = await db.query(
                `UPDATE assignee_leads SET status = 'Lost' WHERE id = ?`,
                [assignmentId]
            );
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = AssigneeLead;
