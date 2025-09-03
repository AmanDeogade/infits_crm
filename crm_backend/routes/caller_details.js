const express = require('express');
const router = express.Router();
const callerDetailsController = require('../controllers/callerDetailsController');

router.get('/', callerDetailsController.getAllCallerDetails);
router.get('/:id', callerDetailsController.getCallerDetailsById);
router.get('/by-caller/:caller_id', callerDetailsController.getCallerDetailsByCallerId);
router.post('/', callerDetailsController.createCallerDetails);
router.put('/:id', callerDetailsController.updateCallerDetails);
router.delete('/:id', callerDetailsController.deleteCallerDetails);

module.exports = router; 