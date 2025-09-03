const express = require('express');
const router = express.Router();
const callerController = require('../controllers/callerController');

router.get('/', callerController.getAllCallers);
router.get('/:id', callerController.getCallerById);
router.post('/', callerController.createCaller);
router.put('/:id', callerController.updateCaller);
router.delete('/:id', callerController.deleteCaller);

module.exports = router; 