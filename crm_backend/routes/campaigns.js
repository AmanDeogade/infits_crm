const express = require('express');
const router = express.Router();
const campaignController = require('../controllers/campaignController');
const authenticateToken = require('../middleware/authenticateToken');

router.post('/', authenticateToken, campaignController.createCampaign);
router.get('/', campaignController.getAllCampaigns);
router.get('/dashboard/stats', campaignController.getCampaignDashboardStats);
router.get('/:id', campaignController.getCampaignById);
router.put('/:id', authenticateToken, campaignController.updateCampaign);
router.delete('/:id', authenticateToken, campaignController.deleteCampaign);

module.exports = router; 