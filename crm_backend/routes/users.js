const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authenticateToken = require('../middleware/authenticateToken');

router.get('/', userController.getAllUsers);
router.get('/admins', authenticateToken, userController.getAdminUsers);
router.get('/:id', authenticateToken, userController.getUserById);
router.get('/role/:role', authenticateToken, userController.getUsersByRole);
router.get('/reporting-to/:reportingTo', authenticateToken, userController.getUsersByReportingTo);
router.put('/:id', userController.updateUser);
router.put('/:id/role', authenticateToken, userController.updateUserRole);
router.put('/:id/reporting-to', authenticateToken, userController.updateUserReportingTo);
router.delete('/:id', authenticateToken, userController.deleteUser);
router.post('/sync-callers', authenticateToken, userController.syncCallersTable);

module.exports = router; 