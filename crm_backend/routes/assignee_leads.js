const express = require('express');
const router = express.Router();
const assigneeLeadModel = require('../models/assignee_lead');
const authenticateToken = require('../middleware/authenticateToken');

// Apply authentication middleware to all routes
router.use(authenticateToken);

// Get all assignee_lead records for a specific campaign
router.get('/campaign/:campaignId', async (req, res) => {
    try {
        const { campaignId } = req.params;
        const assignments = await assigneeLeadModel.getByCampaignId(campaignId);
        res.json({ 
            success: true, 
            assignments,
            message: `Found ${assignments.length} assignments for campaign ${campaignId}`
        });
    } catch (error) {
        console.error('Error fetching assignee_lead records:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error',
            details: error.message 
        });
    }
});

// Get all assignee_lead records for a specific assignee (user)
router.get('/assignee/:assigneeId', async (req, res) => {
    try {
        const { assigneeId } = req.params;
        const assignments = await assigneeLeadModel.getByAssigneeId(assigneeId);
        res.json({ 
            success: true, 
            assignments,
            message: `Found ${assignments.length} assignments for assignee ${assigneeId}`
        });
    } catch (error) {
        console.error('Error fetching assignee_lead records:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error',
            details: error.message 
        });
    }
});

// Get assignee_lead record for a specific lead
router.get('/lead/:leadId', async (req, res) => {
    try {
        const { leadId } = req.params;
        const assignment = await assigneeLeadModel.getByLeadId(leadId);
        if (assignment) {
            res.json({ 
                success: true, 
                assignment,
                message: 'Assignment found'
            });
        } else {
            res.status(404).json({ 
                success: false, 
                error: 'Assignment not found for this lead'
            });
        }
    } catch (error) {
        console.error('Error fetching assignee_lead record:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error',
            details: error.message 
        });
    }
});

// Update assignment status
router.put('/:assignmentId/status', async (req, res) => {
    try {
        const { assignmentId } = req.params;
        const { status, notes } = req.body;
        
        if (!status) {
            return res.status(400).json({ 
                success: false, 
                error: 'Status is required' 
            });
        }
        
        const updated = await assigneeLeadModel.updateStatus(assignmentId, status, notes);
        if (updated) {
            res.json({ 
                success: true, 
                message: 'Assignment status updated successfully'
            });
        } else {
            res.status(404).json({ 
                success: false, 
                error: 'Assignment not found' 
            });
        }
    } catch (error) {
        console.error('Error updating assignment status:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error',
            details: error.message 
        });
    }
});

// Get all assignee_lead records (for admin purposes)
router.get('/', async (req, res) => {
    try {
        const assignments = await assigneeLeadModel.getAll();
        res.json({ 
            success: true, 
            assignments,
            message: `Found ${assignments.length} total assignments`
        });
    } catch (error) {
        console.error('Error fetching all assignee_lead records:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Internal server error',
            details: error.message 
        });
    }
});

module.exports = router;
