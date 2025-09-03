const express = require('express');
const router = express.Router();
const assigneeController = require('../controllers/assigneeController');

// Get assignee lead statistics by stage for dashboard
router.get('/lead-stats', assigneeController.getAssigneeLeadStats);

// Get follow-up statistics for all assignees
router.get('/follow-up-stats', assigneeController.getFollowUpStats);

// Get statistics for a specific assignee
router.get('/:assigneeId/stats', assigneeController.getAssigneeStats);

module.exports = router;
