const express = require('express');
const router = express.Router();
const callMetricsController = require('../controllers/callMetricsController');

router.get('/', callMetricsController.getAllCallMetrics);
router.get('/:id', callMetricsController.getCallMetricsById);
router.get('/by-user/:user_id', callMetricsController.getCallMetricsByUserId);
router.post('/', callMetricsController.createCallMetrics);
router.put('/:id', callMetricsController.updateCallMetrics);
router.delete('/:id', callMetricsController.deleteCallMetrics);

module.exports = router; 