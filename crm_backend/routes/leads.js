const express = require('express');
const router = express.Router();
const leadController = require('../controllers/leadController');
const authenticateToken = require('../middleware/authenticateToken');

router.post('/', authenticateToken, leadController.createLead);
router.post('/bulk', authenticateToken, leadController.bulkCreateLeads);
router.post('/bulk-assign', authenticateToken, leadController.bulkAssignLeads);
router.get('/', leadController.getAllLeads);
router.get('/:id', leadController.getLeadById);
router.get('/assignee/:assignee_id', leadController.getLeadsByAssignee);
router.get('/campaign/:campaign_id/unassigned', leadController.getUnassignedLeads);
router.put('/:id', leadController.updateLead);
router.put('/:lead_id/assign/:assignee_id', leadController.assignLead);
router.put('/:lead_id/unassign', leadController.unassignLead);
router.delete('/:id', leadController.deleteLead);

module.exports = router;