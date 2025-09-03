const express = require('express');
const router = express.Router();
const campaignAssigneeController = require('../controllers/campaignAssigneeController');
const authenticateToken = require('../middleware/authenticateToken');

// Apply authentication middleware to all routes
router.use(authenticateToken);

// Assign a user to a campaign
router.post('/assign', campaignAssigneeController.assignUserToCampaign);

// Get all assignees for a specific campaign
router.get('/campaign/:campaign_id', campaignAssigneeController.getCampaignAssignees);

// Get all campaigns for a specific user
router.get('/user/:user_id', campaignAssigneeController.getUserCampaigns);

// Update an assignment (role, active status, etc.)
router.put('/assignment/:assignment_id', campaignAssigneeController.updateAssignment);

// Remove a user from a campaign (soft delete)
router.delete('/campaign/:campaign_id/user/:user_id', campaignAssigneeController.removeUserFromCampaign);

// Delete an assignment completely (hard delete)
router.delete('/assignment/:assignment_id', campaignAssigneeController.deleteAssignment);

module.exports = router; 