const express = require('express');
const router = express.Router();
const filterUserController = require('../controllers/filterUserController');
const authenticateToken = require('../middleware/authenticateToken');

// Apply authentication middleware to all routes
router.use(authenticateToken);

// GET /api/filter-users - Get all filter users
router.get('/', filterUserController.getAllFilterUsers);

// GET /api/filter-users/:id - Get filter user by ID
router.get('/:id', filterUserController.getFilterUserById);

// POST /api/filter-users - Create a new filter user
router.post('/', filterUserController.createFilterUser);

// PUT /api/filter-users/:id - Update a filter user
router.put('/:id', filterUserController.updateFilterUser);

// DELETE /api/filter-users/:id - Delete a filter user
router.delete('/:id', filterUserController.deleteFilterUser);

// GET /api/filter-users/search/email - Search filter users by email
router.get('/search/email', filterUserController.searchByEmail);

// GET /api/filter-users/search/date-range - Search filter users by date range
router.get('/search/date-range', filterUserController.searchByDateRange);

// GET /api/filter-users/search/name - Search filter users by name
router.get('/search/name', filterUserController.searchByName);

// POST /api/filter-users/bulk - Bulk create filter users
router.post('/bulk', filterUserController.bulkCreateFilterUsers);

module.exports = router; 